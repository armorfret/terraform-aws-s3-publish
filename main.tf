terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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
  count  = var.make_bucket
}

resource "aws_s3_bucket_acl" "vantage_bucket_acl" {
  bucket = aws_s3_bucket.this[count.index].id
  count  = var.make_bucket
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this[count.index].id
  count                   = var.make_bucket
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
  count = var.make_bucket
}

resource "aws_s3_bucket_logging" "this" {
  bucket        = aws_s3_bucket.this[count.index].id
  target_bucket = var.logging_bucket
  target_prefix = "${var.publish_bucket}/"
  count         = var.make_bucket
}

#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "this" {
  name = "s3-publish-${var.publish_bucket}"
}

