# S3 Bucket Encryption with KMS - Terraform Full Setup

provider "aws" {
  region = "us-east-1"
}

# 1. Create a KMS key
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for encrypting S3 bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3BucketKey"
  target_key_id = aws_kms_key.s3_key.id
}

# 2. Create an S3 bucket with default encryption
resource "aws_s3_bucket" "kms_bucket" {
  bucket = "my-kms-encrypted-bucket-23"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.kms_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# 3. IAM Policy for user to access S3 + KMS
resource "aws_iam_policy" "s3_kms_access" {
  name        = "S3KMSAccessPolicy"
  description = "Policy for user to access S3 bucket with KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowS3Read",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.kms_bucket.arn,
          "${aws_s3_bucket.kms_bucket.arn}/*"
        ]
      },
      {
        Sid = "AllowKMSUsage",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.s3_key.arn
      }
    ]
  })
}

# 4. Attach policy to specific IAM user (replace with actual user name)
resource "aws_iam_user" "example_user" {
  name = "kms"
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.s3_kms_access.arn
}

# 5. Optional: Add KMS key policy for IAM user
resource "aws_kms_key" "s3_key_with_policy" {
  description = "KMS Key with custom policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Id = "kms-key-policy",
    Statement = [
      {
        Sid = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Sid = "Allow access for user",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.example_user.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}
