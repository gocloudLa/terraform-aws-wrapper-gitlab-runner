module "gitlab_runner" {
  source  = "cattle-ops/gitlab-runner/aws"
  version = "9.2.3"

  count       = local.gitlab_runner_enable
  environment = try(var.gitlab_runner_parameters.environment, local.metadata.key.env)

  # Gitlab monitoring

  runner_cloudwatch = {
    enable         = try(var.gitlab_runner_parameters.enable_cloudwatch, true)
    log_group_name = try(var.gitlab_runner_parameters.log_group_name, "${local.common_name}-gitlab-runner")
    retention_days = try(var.gitlab_runner_parameters.retention_days, 30)
  }

  # Gitlab instance settings

  runner_instance = {
    collect_autoscaling_metrics = try(var.gitlab_runner_parameters.collect_autoscaling_metrics, [])
    ebs_optimized               = try(var.gitlab_runner_parameters.ebs_optimized, false)
    monitoring                  = try(var.gitlab_runner_parameters.monitoring, false)
    name                        = try(var.gitlab_runner_parameters.name, "${local.common_name}-gitlab_runner")
    name_prefix                 = try(var.gitlab_runner_parameters.name_prefix, "${local.common_name}-gitlab_runner")
    private_address_only        = try(var.gitlab_runner_parameters.private_address_only, false)
    root_device_config          = try(var.gitlab_runner_parameters.root_device_config, { volume_size = 30 })
    spot_price                  = try(var.gitlab_runner_parameters.spot_price, "on-demand-price")
    ssm_access                  = try(var.gitlab_runner_parameters.ssm_access, true)
    type                        = try(var.gitlab_runner_parameters.instance_type, "t3.medium")
    use_eip                     = try(var.gitlab_runner_parameters.use_eip, false)
  }

  # Gitlab runner settings

  runner_gitlab = {
    runner_version                           = try(var.gitlab_runner_parameters.runner_version, "17.0.0")
    url                                      = try(var.gitlab_runner_parameters.url, "https://gitlab.com")
    access_token_secure_parameter_store_name = try(var.gitlab_runner_parameters.access_token_secure_parameter_store_name, "")
    registration_token                       = try(var.gitlab_runner_parameters.runner_registration_token, null)
  }

  runner_ami_filter = try(var.gitlab_runner_parameters.ami_filter, { name = ["amzn2-ami-hvm-2.*-x86_64-ebs"] })

  # Gitlab runner role settings

  runner_role = {
    allow_iam_service_linked_role_creation = try(var.gitlab_runner_parameters.allow_iam_service_linked_role_creation, true)
    create_role_profile                    = try(var.gitlab_runner_parameters.create_role_profile, true)
  }

  iam_object_prefix = try(var.gitlab_runner_parameters.iam_object_prefix, "${local.common_name}-gitlab_runner")

  runner_manager = {
    gitlab_check_interval   = try(var.gitlab_runner_parameters.gitlab_check_interval, 3)
    maximum_concurrent_jobs = try(var.gitlab_runner_parameters.maximum_concurrent_jobs, 3)
  }

  # Gitlab worker settings

  runner_worker = {
    max_jobs            = try(var.gitlab_runner_parameters.max_jobs, 0)
    output_limit        = try(var.gitlab_runner_parameters.output_limit, 4096)
    request_concurrency = try(var.gitlab_runner_parameters.request_concurrency, 3)
    ssm_access          = try(var.gitlab_runner_parameters.ssm_access, false)
    type                = try(var.gitlab_runner_parameters.type, "docker") // "docker+machine"
  }

  runner_worker_docker_options = {
    disable_cache = try(var.gitlab_runner_parameters.disable_cache, "false")
    image         = try(var.gitlab_runner_parameters.image, "docker:18.03.1-ce")
    privileged    = try(var.gitlab_runner_parameters.privileged, "true")
    pull_policies = try(var.gitlab_runner_parameters.pull_policies, ["always"])
    shm_size      = try(var.gitlab_runner_parameters.shm_size, 0)
    tls_verify    = try(var.gitlab_runner_parameters.tls_verify, "false")
    volumes       = try(var.gitlab_runner_parameters.volumes, ["/cache"])
  }

  # Gitlab worker volume settings

  runner_worker_docker_add_dind_volumes = try(var.gitlab_runner_parameters.runner_worker_docker_add_dind_volumes, true)

  runner_worker_docker_volumes_tmpfs = try(var.gitlab_runner_parameters.runner_worker_docker_volumes_tmpfs, [])

  # Gitlab autoscalling settings

  runner_schedule_enable = try(var.gitlab_runner_parameters.enable_schedule, false)
  runner_schedule_config = try(var.gitlab_runner_parameters.schedule_config, {})

  # Networking

  runner_networking = {
    allow_incoming_ping                    = try(var.gitlab_runner_parameters.allow_incoming_ping, false)
    allow_incoming_ping_security_group_ids = try(var.gitlab_runner_parameters.allow_incoming_ping_security_group_ids, [])
    security_group_description             = try(var.gitlab_runner_parameters.security_group_description, "A security group containing gitlab-runner agent instances")
    security_group_ids                     = try(var.gitlab_runner_parameters.security_group_ids, [])
  }

  security_group_prefix = try(var.gitlab_runner_parameters.security_group_prefix, "${local.common_name}-gitlab_runner")

  vpc_id    = data.aws_vpc.this.id
  subnet_id = element(data.aws_subnets.this.ids, 0)

  # Runner cache

  runner_worker_cache = {
    access_log_bucket_id                     = try(var.gitlab_runner_parameters.access_log_bucket_id, null)
    access_log_bucket_prefix                 = try(var.gitlab_runner_parameters.access_log_bucket_prefix, null)
    authentication_type                      = try(var.gitlab_runner_parameters.authentication_type, "iam")
    bucket                                   = try(var.gitlab_runner_parameters.bucket, null)
    bucket_prefix                            = try(var.gitlab_runner_parameters.bucket_prefix, "${local.common_name}")
    create                                   = try(var.gitlab_runner_parameters.create, true)
    create_aws_s3_bucket_public_access_block = try(var.gitlab_runner_parameters.create_aws_s3_bucket_public_access_block, true)
    expiration_days                          = try(var.gitlab_runner_parameters.expiration_days, 1)
    include_account_id                       = try(var.gitlab_runner_parameters.include_account_id, false)
    random_suffix                            = try(var.gitlab_runner_parameters.random_suffix, false)
    shared                                   = try(var.gitlab_runner_parameters.shared, false)
    versioning                               = try(var.gitlab_runner_parameters.versioning, false)
  }

  # tags = local.common_tags

}

## IAM POLICY PARA RUNNER
resource "aws_iam_role_policy_attachment" "gitlab_runner" {
  count = local.gitlab_runner_enable

  role       = module.gitlab_runner[0].runner_agent_role_name
  policy_arn = aws_iam_policy.gitlab_runner[0].arn
}

resource "aws_iam_policy" "gitlab_runner" {
  count = local.gitlab_runner_enable

  name   = "${local.common_name}-gitlab-runner"
  path   = "/"
  policy = data.aws_iam_policy_document.gitlab_runner.json
}

## IAM ROLE PARA ACCESO DESDE SHARED RUNNER
resource "aws_iam_policy" "gitlab_runner_accounts_role" {
  count = lookup(var.gitlab_runner_parameters, "assumable_role_enable", false) ? 1 : 0

  name   = "${local.common_name}-gitlab-runner-assumable"
  path   = "/"
  policy = data.aws_iam_policy_document.gitlab_runner_accounts_role.json
}

module "iam_assumable_role_terraform_runner" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.1"
  trust_policy_permissions = {
    AllowAssumeRole = {
      principals = [{
        type        = "AWS"
        identifiers = [lookup(var.gitlab_runner_parameters, "assumable_role_trusted_role_arn", "")]
      }]
    }
  }
  create_instance_profile = false
  max_session_duration    = 3600
  create                  = lookup(var.gitlab_runner_parameters, "assumable_role_enable", false)

  name = "${local.common_name}-gitlab-runner-assumable"

  policies = try(aws_iam_policy.gitlab_runner_accounts_role[0].arn, {})
}