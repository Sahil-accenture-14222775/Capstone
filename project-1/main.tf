# Get AWS Account ID
data "aws_caller_identity" "current" {}

# Create S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  force_destroy = true

  tags = {
    Name        = var.project_name
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow Public Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Make Website Public
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.website.id

  depends_on = [
    aws_s3_bucket_public_access_block.public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Upload HTML Website
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"

  etag = filemd5("${path.module}/index.html")

  depends_on = [
    aws_s3_bucket_website_configuration.site
  ]
}
