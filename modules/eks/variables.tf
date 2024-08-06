variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "capacity_type" {
  description = "Capacity type for the EKS node group (e.g., ON_DEMAND, SPOT)"
  type        = string
}

variable "instance_types" {
  description = "List of EC2 instance types to use for the EKS node group"
  type        = list(string)
}

variable "scaling_config" {
  description = "Configuration for scaling the EKS node group"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = null
}

variable "update_config" {
  description = "Configuration for updating the EKS node group"
  type = object({
    max_unavailable = number
  })
  default = null
}

variable "labels" {
  description = "Labels to apply to the EKS node group"
  type = object({
    role = string
  })
  default = null
}

variable "region" {
  description = "AWS region where the EKS cluster and resources are deployed"
  type        = string
}

variable "iam_node_role_name" {
  description = "Name of the IAM role for the EKS node group"
  type        = string
}

variable "assume_role_node_policy" {
  description = "IAM policy to attach to the node role"
  type        = string
}

variable "assume_role_cluster_policy" {
  description = "IAM policy to attach to the cluster role"
  type        = string
}

variable "iam_cluster_role_name" {
  description = "Name of the IAM role for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the EKS node group will be deployed"
  type        = list(string)
}

variable "node_group_names" {
  description = "List of names for the EKS node groups"
  type        = list(string)
}
