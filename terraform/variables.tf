variable "resume_bucket" {
  description = "Bucket storing the static site"
  type        = string
}
variable "artifacts_bucket" {
  description = "Bucket storing the artifacts of code pipeline"
  type        = string
}