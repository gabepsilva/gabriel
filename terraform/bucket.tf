resource "aws_s3_bucket" "resume_bucket" {
  bucket = var.resume_bucket
}

resource "aws_s3_bucket_acl" "resume_bucket_acl" {
  bucket = aws_s3_bucket.resume_bucket.id
  acl    = "private"
}