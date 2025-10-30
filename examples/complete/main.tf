module "wrapper_gitlab_runner" {
  source = "../../"

  metadata = local.metadata

  gitlab_runner_parameters = {
    enable                    = true
    runner_registration_token = "" # var.gitlab_registration_token
    instance_type             = "t3.medium"
    enable_schedule           = true
    schedule_config           = local.asg_schedules
    ami_filter                = { name = ["al2023-ami-2023*-x86_64"] }

    # Para habilitar instancias On Demand habilitar la siguiente línea: 
    #spot_price                = null 

    # Network Settings
    # vpc_name    = "dmc-prd"  # Default: "${local.common_name}"
    # subnet_name = "dmc-prd-private*" # Default: "${local.common_name}-private*

    # SHARED RUNNER CONFIGURATION 
    # Roles & Policies Settings 
    # attach_default_policy = false # Default Access politycs are not applied
    # Roles configuration that will be assumed in external accounts
    # assumable_roles_arn = [
    #   "arn:aws:iam::123456789012:role/dmc-dev-gitlab-runner-assumable",
    #   "arn:aws:iam::123456789012:role/dmc-stg-gitlab-runner-assumable"
    # ] # Allow Runner to Asume external roles
    # assumable_roles_arn = ["*"] # Allow Runner to Asume external roles
  }
}
# Generates a Role that can be assumed by a Shared Runner
# module "wrapper_gitlab_runner_role" {
#   source = "../../"

#   metadata = local.metadata

#   gitlab_runner_parameters = {
#     enable = false
#     # CONFIG FOR JUST CREATING THE ROLE AND GIVING ACCESS TO AN EXTERN RUNNER ( shared )
#     assumable_role_enable = true
#     # Shared Runner Instance Role ARN
#     assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:role/dmc-sha-gitlab_runner-instance"
#     # Insecure Option, allow an external account to assume this role
#     # assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:root"

#     # additional_policy_json = data.aws_iam_policy_document.this.json
#   }
# }