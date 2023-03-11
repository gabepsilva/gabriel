#########################
## LOGGING BUCKET
#########################
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket
  tags = var.tags
}

// Ensure private bucket
resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

##############################
## SSL CERTIFICATE REQUEST
##############################

resource "aws_acm_certificate" "gabriel_certificate" {
  domain_name       = var.fqns
  validation_method = "DNS"
  tags = var.tags
}

#####################################
## CLOUDFRONT DISTRIBUTION
#####################################
resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = aws_s3_bucket.resume_bucket.bucket
  description                       = "Sign but not override"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {

  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }

  aliases = ["${var.fqns}"]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${aws_s3_bucket.resume_bucket.bucket}"
  default_root_object = "index.html"

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.gabriel_certificate.arn
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
    prefix          = "cloudfront-logs"
  }

  tags = var.tags
}
