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