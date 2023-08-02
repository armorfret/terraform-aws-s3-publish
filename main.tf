terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    awscreds = {
      source  = "armorfret/awscreds"
      version = "~> 0.6"
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.publish_bucket}/*",
      "arn:aws:s3:::${var.publish_bucket}",
    ]
  }
}

resource "aws_iam_user_policy" "this" {
  name   = "s3-publish"
  user   = aws_iam_user.this.name
  policy = data.aws_iam_policy_document.this.json
}

resource "awscreds_iam_access_key" "this" {
  user = aws_iam_user.this.name
  file = "creds/${aws_iam_user.this.name}"
}

resource "aws_s3_bucket" "this" {
  bucket = var.publish_bucket
  count  = var.make_bucket ? 1 : 0
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.make_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.use_kms ? var.kms_key_arn : null
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = var.make_bucket ? 1 : 0
  bucket = aws_s3_bucket.this[count.index].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this[count.index].id
  count                   = var.make_bucket ? 1 : 0
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
  count = var.make_bucket ? 1 : 0
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this[count.index].id
  target_bucket = var.logging_bucket
  target_prefix = "${var.publish_bucket}/"
  count         = var.make_bucket ? 1 : 0
}

resource "aws_iam_user" "this" { #trivy:ignore:AVD-AWS-0143
  name = "s3-publish-${var.publish_bucket}"
}

