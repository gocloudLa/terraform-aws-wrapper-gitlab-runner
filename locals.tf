locals {
  gitlab_runner_enable = lookup(var.gitlab_runner_parameters, "enable", false) ? 1 : 0

  default_runner_egress_rules = {
    "allow_https_ipv4" = {
      cidr_block  = "0.0.0.0/0"
      description = "Allow HTTPS egress traffic"
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
    }
    "allow_https_ipv6" = {
      description     = "Allow HTTPS egress traffic (IPv6)"
      from_port       = 443
      ipv6_cidr_block = "::/0"
      protocol        = "tcp"
      to_port         = 443
    }
  }
}
