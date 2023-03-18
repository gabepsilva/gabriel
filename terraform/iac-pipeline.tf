#########################
## ARTIFACT BUCKET
#########################

resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
  bucket = var.artifacts_bucket
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_artifact_bucket.id
  acl    = "private"
}


#########################
## CODE BUILD ROLE
#########################

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.codebuild_role.name
}

#########################
## CODE BUILD PROJECT
#########################
resource "aws_codebuild_project" "apply_terraform_project" {
  name          = "resume_build_deploy"
  description   = "Build and deploy resume"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "IAC"
      value = "TRUE"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  tags = var.tags
}


#########################
## PIPELINE ROLE
#########################

resource "aws_codestarconnections_connection" "github_conn" {
  name          = "GitHub-Connection"
  provider_type = "GitHub"
  tags          = var.tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      "*"
      #aws_s3_bucket.codepipeline_artifact_bucket.arn,
      #"${aws_s3_bucket.codepipeline_artifact_bucket.arn}/"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github_conn.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}

#########################
## ENABLE CODEPIPELINE TO ASSUME ROLE
#########################
resource "aws_iam_role" "codepipeline_role" {
  name               = "terraform_codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#########################
## PIPELINE
#########################
resource "aws_codepipeline" "terraform_pipeline" {
  name     = "resume_build_deploy_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"


    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]



      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_conn.arn
        FullRepositoryId = var.full_repository_id
        BranchName       = var.build_branch
        OutputArtifactFormat: "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order        = "1"

      configuration = {
        ProjectName = aws_codebuild_project.apply_terraform_project.name

        EnvironmentVariables = jsonencode([
          {
            name  = "IAC"
            value = "true"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployAction"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["BuildOutput"]
      configuration = {
        BucketName = aws_s3_bucket.resume_bucket.bucket
        Extract    = true
        #ObjectKey  = ""
      }
    }
  }

  tags = var.tags
}
