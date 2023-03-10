#!/bin/bash


# Retrieve the account ID for the current AWS user or role
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

if [ -z "${ACCOUNT_ID}" ]; then
  echo "Failed to retrieve account id."
  echo "Are you authenticated?"
  exit 1
fi

# Set the name of the Terraform backend S3 bucket
TF_BACKEND_BUCKET='gabriel-resume-state-file'

# Check if the bucket already exists
if aws s3 ls "s3://${TF_BACKEND_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
  # Create the bucket
  aws s3 mb "s3://${TF_BACKEND_BUCKET}"
  echo "Created S3 bucket s3://${TF_BACKEND_BUCKET}"
else
  echo "S3 bucket s3://${TF_BACKEND_BUCKET} already exists"
fi
