data "aws_caller_identity" "current" {}

/*----------------------------------------------------------------------*/
/* NetWorking | datasources                                             */
/*----------------------------------------------------------------------*/
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = [
      try(var.gitlab_runner_parameters.vpc_name, local.default_vpc_name)
    ]
  }
}


data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Name = try(var.gitlab_runner_parameters.subnet_name, local.default_subnet_name)
  }
}

/*----------------------------------------------------------------------*/
/* GitLab | datasources                                                 */
/*----------------------------------------------------------------------*/

data "aws_iam_policy_document" "gitlab_runner_default" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [
      "arn:aws:ecr:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.common_name}*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode",
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:function:*${local.common_name}*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "events:ListTargetsByRule",
      "events:PutTargets"
    ]
    resources = [
      "arn:aws:events:${local.metadata.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${local.common_name}*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${local.common_name}*"
    ]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
  }
}

data "aws_iam_policy_document" "gitlab_runner" {
  source_policy_documents = [
    local.default_policy,
    local.additional_policy_json
  ]

  dynamic "statement" {
    for_each = try(var.gitlab_runner_parameters.assumable_roles_arn, false) != false ? { validate = true } : {}
    content {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      resources = lookup(var.gitlab_runner_parameters, "assumable_roles_arn", [])
    }
  }
}

data "aws_iam_policy_document" "gitlab_runner_accounts_role" {
  source_policy_documents = [
    local.default_policy,
    local.additional_policy_json
  ]
}

locals {
  default_policy         = try(var.gitlab_runner_parameters.attach_default_policy, true) != false ? data.aws_iam_policy_document.gitlab_runner_default.json : "{}"
  additional_policy_json = try(var.gitlab_runner_parameters.additional_policy_json, "{}")
}
