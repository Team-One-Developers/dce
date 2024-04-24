resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-bucket"
}

/* Force SSL */

resource "aws_s3_bucket_policy" "state_force_ssl" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.state_force_ssl.json
}

data "aws_iam_policy_document" "state_force_ssl" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

/* Enable bucket versioning */

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

/* Move versioned data to cheaper storage class and delete after some time */

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id = "expire-versioned-data"

    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days           = 120
    }
  }
}
