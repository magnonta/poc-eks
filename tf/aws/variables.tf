variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, production)"
  type        = string
}

variable "region" {
  description = "The region where the resources will be deployed (e.g., us-west1, eu-central-1)"
  type        = string
}

variable "namespace" {
  description = "O namespace onde o segredo será criado."
  type        = string
}

variable "docker_username" {
  description = "O nome de usuário para autenticação no Docker registry."
  type        = string
}

variable "docker_password" {
  description = "A senha para autenticação no Docker registry."
  type        = string
  sensitive   = true
}

variable "docker_email" {
  description = "O email associado à conta do Docker registry."
  type        = string
}

variable "aws_access_key_id" {
  description = "The AWS access key ID for programmatic access"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key_id" {
  description = "The AWS secret access key ID for programmatic access"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username for the database"
  type        = string
}

variable "db_database" {
  description = "Name of the database"
  type        = string
}

# variable "account_id" {
#   description = "The AWS account ID where resources will be managed"
#   type        = string
# }

# variable "oidc_provider" {
#   description = "The OIDC provider URL for EKS cluster"
#   type        = string
# }

# variable "service_account_name" {
#   description = "The name of the Kubernetes service account"
#   type        = string
# }

# variable "policy_arn" {
#   description = "The ARN of the IAM policy to be attached"
#   type        = string
# }

# variable "role_name" {
#   description = "The name of the IAM role"
#   type        = string
# }
