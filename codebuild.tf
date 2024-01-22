# #For creating a repository to commit the code in code commit
# #The code below is used

resource "aws_codecommit_repository" "dajmoxcodecommit" {
  repository_name = "dajmoxRepo"
  description     = "Repository to commit my files :D"
}

# resource "aws_codebuild_project" "code_build" {
#   name         = "dajmoxCB"
#   service_role = aws_iam_role.code_build.arn

#   source {
#     type            = "CODECOMMIT"
#     location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/dajmoxRepo"
#     git_clone_depth = 1

#   }

#   environment {
#     compute_type = "BUILD_GENERAL1_SMALL"
#     image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
#     type         = "LINUX_CONTAINER"

#   }

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

# }


resource "aws_codebuild_report_group" "example" {
  name = "example"
  type = "TEST"

  export_config {
    type = "NO_EXPORT"
  }
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
     
    }
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "example" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.dajmox.arn,
      "${aws_s3_bucket.dajmox.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.example.name
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_codebuild_project" "example" {
  name          = "test-project"
  description   = "test_codebuild_project"
  build_timeout = 5
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.dajmox.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.dajmox.id}/build-log"
    }
  }

    source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/dajmoxRepo"
    git_clone_depth = 1

  }
# 
  source_version = "a0d0e9248062c92c5bc4f78e7dbd28966d96610e"

  

  tags = {
    Environment = "Test"
  }
}

resource "aws_codebuild_project" "project-with-cache" {
  name           = "test-project-cache"
  description    = "test_codebuild_project_cache"
  build_timeout  = 5
  queued_timeout = 5

  service_role = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "SOME_KEY1"
      value = "SOME_VALUE1"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/dajmoxRepo"
    git_clone_depth = 1

  }

  tags = {
    Environment = "Test"
  }
}