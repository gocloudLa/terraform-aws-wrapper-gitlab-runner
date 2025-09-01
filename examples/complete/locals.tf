locals {

  metadata = {
    aws_region  = "us-east-1"
    environment = "Production"

    public_domain  = "democorp.cloud"
    private_domain = "democorp"

    key = {
      company = "dmc"
      region  = "use1"
      env     = "prd"
    }
  }

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

  asg_schedules = {
    scale_in_recurrence  = "0 01 * * *"
    scale_in_count       = 0
    scale_in_time_zone   = "Etc/UTC"
    scale_out_recurrence = "0 12 * * 1-5"
    scale_out_count      = 1
    scale_out_time_zone  = "Etc/UTC"
  }
}
