locals {
  metadata = var.metadata

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }

  gitlab_runner_enable = lookup(var.gitlab_runner_parameters, "enable", false) ? 1 : 0
  default_vpc_name     = local.common_name
  default_subnet_name  = "${local.common_name}-private*"

}
