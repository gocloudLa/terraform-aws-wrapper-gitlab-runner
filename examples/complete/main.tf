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

    # Network Settings
    # vpc_name    = "dmc-prd"  # Default: "${local.common_name}"
    # subnet_name = "dmc-prd-private*" # Default: "${local.common_name}-private*

    # CONFIGURACION COMO SHARED RUNNER
    # Roles & Policies Settings 
    # attach_default_policy = false # No Aplico Politicas de Acceso Default
    # Configuro Roles que voy a asumir en cuentas externas
    # assumable_roles_arn = [
    #   "arn:aws:iam::123456789012:role/dmc-dev-gitlab-runner-assumable",
    #   "arn:aws:iam::123456789012:role/dmc-stg-gitlab-runner-assumable"
    # ] # Allow Runner to Asume external roles
    # assumable_roles_arn = ["*"] # Allow Runner to Asume external roles
  }
}

# Solo Genera un Rol que puede ser Asumido por un Shared Runner
# module "wrapper_gitlab_runner_role" {
#   source = "../../"

#   metadata = local.metadata

#   gitlab_runner_parameters = {
#     enable = false

#     # CONFIGURACION PARA SOLO CREAR EL ROL Y DAR ACCESO A UN RUNNER EXTERNO ( shared )
#     assumable_role_enable = true
#     # ARN del rol de la instancia del Shared Runner
#     assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:role/dmc-sha-gitlab_runner-instance"
#     # Opcion Insegura, permitir asumir este rol a una cuenta externa
#     # assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:root"

#     # additional_policy_json = data.aws_iam_policy_document.this.json
#   }
# }