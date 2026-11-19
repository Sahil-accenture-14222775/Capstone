output "s3_bucket_name" {
  value = aws_s3_bucket.website.id
}

output "website_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}"
}

output "aws_region" {
  value = var.aws_region
}
