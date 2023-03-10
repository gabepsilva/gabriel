#########################
## LOGGING BUCKET
#########################
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket
}

// Ensure private bucket
resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

#####################################
## CLOUDFRONT DISTRIBUTION
#####################################
#resource "aws_cloudfront_origin_access_identity" "s3_origin_access_identity" {
#  comment = "CloudFront origin access identity for S3 bucket"
#}

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


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${aws_s3_bucket.resume_bucket.bucket}"
  default_root_object = "index.html"
  #price_class         = "PriceClass_100"

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
    cloudfront_default_certificate = true
  }

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
    prefix          = "cloudfront-logs"
  }

}

