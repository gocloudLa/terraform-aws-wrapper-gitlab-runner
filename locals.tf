locals {
  gitlab_runner_enable = lookup(var.gitlab_runner_parameters, "enable", false) ? 1 : 0
}
