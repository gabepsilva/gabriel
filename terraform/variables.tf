####################
# BUCKETS
####################
variable "resume_bucket" {
  description = "Bucket storing the static site"
  type        = string
}

variable "artifacts_bucket" {
  description = "Bucket storing the artifacts of code pipeline"
  type        = string
}

variable "logging_bucket" {
  description = "Bucket storing Cloudfront logs"
  type        = string
}


####################
# Git Settings
####################
variable "build_branch" {
  description = "Branch to be built"
  type        = string
}

variable "full_repository_id" {
  description = "Repo to be built"
  type        = string
}

####################
# Domain Settings
####################
variable "fqns" {
  description = "CloudFront alternate domain"
  type        = string
}
