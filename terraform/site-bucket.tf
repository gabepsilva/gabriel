#########################
## STATIC SITE BUCKET
#########################

resource "aws_s3_bucket" "resume_bucket" {
  bucket = var.resume_bucket
}

// Ensure private bucket
resource "aws_s3_bucket_acl" "resume_bucket_acl" {
  bucket = aws_s3_bucket.resume_bucket.id
  acl    = "private"
}

// Policy to allow Cloudfront distribution
resource "aws_s3_bucket_policy" "example_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.bucket

  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
      {
        "Sid": "AllowCloudFrontServicePrincipal",
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${var.resume_bucket}/*",
        "Condition": {
          "StringLike": {
            "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
          }
        }
      }
    ]
  })
}
