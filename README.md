# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform GitLab Runner Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-gitlab-runner/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-gitlab-runner.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-gitlab-runner.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-gitlab-runner/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for GitLab Runner simplifies the configuration of the GitLab Runner Service in the AWS cloud.

### ✨ Features

- 🏃‍♀️ [Shared Runner](#shared-runner) - Shared GitLab Runner that can assume roles in external accounts

- 🔑 [Assumed Role](#assumed-role) - Generates IAM roles for external Gitlab Runner access

- 🔒 [Custom Policy](#custom-policy) - Add specific access policies through statements in JSON.



### 🔗 External Modules
| Name | Version |
|------|------:|
| [cattle-ops/gitlab-runner/aws](https://github.com/cattle-ops/gitlab-runner-aws) | 9.2.2 |
| [terraform-aws-modules/iam/aws](https://github.com/terraform-aws-modules/iam-aws) | 5.45.0 |



## 🚀 Quick Start
```hcl
gitlab_runner_parameters = {
    enable                    = true
    runner_registration_token = var.gitlab_registration_token
    instance_type             = "t3.medium"
    enable_schedule           = true
    schedule_config           = local.asg_schedules
    ami_filter                = { name = ["amzn2-ami-hvm-2.0.20230822.0-x86_64-ebs"] }

    # Network Settings
    # vpc_name    = "dmc-prd"  # Default: "${local.common_name}"
    # subnet_name = "dmc-prd-private*" # Default: "${local.common_name}-private*
  }
```


## 🔧 Additional Features Usage

### Shared Runner
Configure a GitLab Runner to be used in a shared manner (shared among various environments). This particular runner does not configure policies to access account resources but enables the ability to assume roles in external accounts.


<details><summary>Configuration Code</summary>

```hcl
gitlab_runner_parameters = {
    enable                    = true
    runner_registration_token = var.gitlab_registration_token
    instance_type             = "t3.medium"
    enable_schedule           = true
    schedule_config           = local.asg_schedules
    ami_filter                = { name = ["amzn2-ami-hvm-2.0.20230822.0-x86_64-ebs"] }

    # Network Settings
    # vpc_name    = "dmc-prd"  # Default: "${local.common_name}"
    # subnet_name = "dmc-prd-private*" # Default: "${local.common_name}-private*

    # CONFIGURACION COMO SHARED RUNNER
    # Roles & Policies Settings 
    attach_default_policy = false # No Aplico Politicas de Acceso Default
    # Configuro Roles que voy a asumir en cuentas externas
    assumable_roles_arn = [
      "arn:aws:iam::123456789012:role/dmc-dev-gitlab-runner-assumable",
      "arn:aws:iam::123456789012:role/dmc-stg-gitlab-runner-assumable"
    ] # Allow Runner to Asume external roles
    # assumable_roles_arn = ["*"] # Allow Runner to Asume external roles
  }
```


</details>


### Assumed Role
It does not generate infrastructure to run the Gitlab Runner but it does generate the roles that will give access to the AWS account for External Runners.


<details><summary>Configuration Code</summary>

```hcl
gitlab_runner_parameters = {
    enable = false

    # CONFIGURACION PARA SOLO CREAR EL ROL Y DAR ACCESO A UN RUNNER EXTERNO ( shared )
    assumable_role_enable           = true
    # ARN del rol de la instancia del Shared Runner
    assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:role/dmc-sha-gitlab_runner-instance"
    # Opcion Insegura, permitir asumir este rol a una cuenta externa
    # assumable_role_trusted_role_arn = "arn:aws:iam::123456789012:root"

    # additional_policy_json = data.aws_iam_policy_document.this.json # Opcional
  }
```


</details>


### Custom Policy
Add specific access policies through statements in JSON.


<details><summary>Configuration Code</summary>

```hcl
gitlab_runner_parameters = {
    enable                    = true
    runner_registration_token = var.gitlab_registration_token
    instance_type             = "t3.medium"
    enable_schedule           = true
    schedule_config           = local.asg_schedules
    ami_filter                = { name = ["amzn2-ami-hvm-2.0.20230822.0-x86_64-ebs"] }

    additional_policy_json = data.aws_iam_policy_document.this.json
  }
```


</details>




## 📑 Inputs
| Name                                     | Description                                                    | Type     | Default                                       | Required |
| ---------------------------------------- | -------------------------------------------------------------- | -------- | --------------------------------------------- | -------- |
| enable                                   | Whether to enable CloudWatch for the GitLab runner             | `bool`   | `true`                                        | no       |
| log_group_name                           | The name of the CloudWatch log group for the GitLab runner     | `null`   | `"${local.common_name}-gitlab-runner"`        | no       |
| retention_days                           | Number of days to retain logs in CloudWatch                    | `number` | `30`                                          | no       |
| collect_autoscaling_metrics              | List of autoscaling metrics to collect for the runner instance | `list`   | `[]`                                          | no       |
| ebs_optimized                            | Whether the instance should be EBS optimized                   | `bool`   | `false`                                       | no       |
| monitoring                               | Whether to enable detailed monitoring for the instance         | `bool`   | `false`                                       | no       |
| name                                     | Name of the GitLab runner instance                             | `null`   | `"${local.common_name}-gitlab_runner"`        | no       |
| name_prefix                              | Prefix for the instance name                                   | `null`   | `"${local.common_name}-gitlab_runner"`        | no       |
| private_address_only                     | Whether the instance should have only a private IP address     | `bool`   | `false`                                       | no       |
| root_device_config                       | Configuration for the root device volume                       | `map`    | `{ volume_size = 30 }`                        | no       |
| spot_price                               | Spot price for the instance                                    | `null`   | `"on-demand-price"`                           | no       |
| ssm_access                               | Whether to enable SSM access for the instance                  | `bool`   | `true`                                        | no       |
| type                                     | Instance type for the runner                                   | `null`   | `"t3.medium"`                                 | no       |
| use_eip                                  | Whether to assign an Elastic IP to the instance                | `bool`   | `false`                                       | no       |
| runner_version                           | Version of the GitLab runner                                   | `null`   | `"17.0.0"`                                    | no       |
| url                                      | URL of the GitLab instance                                     | `null`   | `"https://gitlab.com"`                        | no       |
| access_token_secure_parameter_store_name | Secure parameter store name for the access token               | `null`   | `""`                                          | no       |
| registration_token                       | Registration token for the runner                              | `null`   | `null`                                        | no       |
| ami_filter                               | AMI filter to use for the GitLab runner instance               | `map`    | `{ name = ["amzn2-ami-hvm-2.*-x86_64-ebs"] }` | no       |
| allow_iam_service_linked_role_creation   | Whether to allow IAM service-linked role creation              | `bool`   | `true`                                        | no       |
| create_role_profile                      | Whether to create a role profile for the runner                | `bool`   | `true`                                        | no       |
| iam_object_prefix                        | Prefix for IAM objects associated with the runner              | `null`   | `"${local.common_name}-gitlab_runner"`        | no       |
| gitlab_check_interval                    | Interval (in minutes) to check GitLab                          | `number` | `3`                                           | no       |
| maximum_concurrent_jobs                  | Maximum number of concurrent jobs                              | `number` | `3`                                           | no       |
| max_jobs                                 | Maximum number of jobs a worker can handle                     | `number` | `0`                                           | no       |
| output_limit                             | Output limit for the worker logs (in MB)                       | `number` | `4096`                                        | no       |
| request_concurrency                      | Concurrency level for worker requests                          | `number` | `3`                                           | no       |
| ssm_access                               | Whether the worker has SSM access                              | `bool`   | `false`                                       | no       |
| type                                     | Worker type (e.g., `docker`, `docker+machine`)                 | `null`   | `"docker"`                                    | no       |
| disable_cache                            | Whether to disable Docker cache                                | `null`   | `"false"`                                     | no       |
| image                                    | Docker image to use for the runner                             | `null`   | `"docker:18.03.1-ce"`                         | no       |
| privileged                               | Whether to run Docker in privileged mode                       | `null`   | `"true"`                                      | no       |
| pull_policies                            | Docker pull policies                                           | `list`   | `["always"]`                                  | no       |
| shm_size                                 | Size of `/dev/shm` (shared memory)                             | `number` | `0`                                           | no       |
| tls_verify                               | Whether to enable TLS verification for Docker                  | `null`   | `"false"`                                     | no       |
| volumes                                  | List of volumes to mount in the Docker container               | `list`   | `["/cache"]`                                  | no       |
| runner_worker_docker_add_dind_volumes    | Whether to add DIND volumes to the Docker runner               | `bool`   | `true`                                        | no       |
| runner_worker_docker_volumes_tmpfs       | List of tmpfs volumes to add to the Docker runner              | `list`   | `[]`                                          | no       |








---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la
- 🐛 **Issues**: [GitHub Issues](https://github.com/gocloudLa/issues)

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 