terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "gabriel-resume-state-file"
    key    = "terraform.tfstate"
  }
}

