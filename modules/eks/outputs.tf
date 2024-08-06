output "arn" {
  description = "The Amazon Resource Name (ARN) of the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.arn }
}

output "node_group_ids" {
  description = "IDs dos grupos de nós EKS"
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.id }
}

output "status" {
  description = "The status of the EKS Node Group (e.g., ACTIVE, CREATING, DELETING, etc.)."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.status }
}

output "resources" {
  description = "The resources associated with the EKS Node Group, such as Auto Scaling groups and security groups."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.resources }
}

output "ami_type" {
  description = "The AMI type for the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.ami_type }
}

output "disk_size" {
  description = "The root device disk size (in GiB) for the EKS Node Group instances."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.disk_size }
}

output "instance_types" {
  description = "The instance types associated with the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.instance_types }
}

output "release_version" {
  description = "The Kubernetes version of the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.release_version }
}

output "subnet_ids" {
  description = "The subnet IDs associated with the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.subnet_ids }
}

output "tags" {
  description = "The tags associated with the EKS Node Group."
  value       = { for k, v in aws_eks_node_group.private-nodes : k => v.tags }
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "endpoint" {
  description = "The endpoint URL for the EKS cluster"
  value       = aws_eks_cluster.eks.endpoint
}

output "certificate_authority" {
  description = "The base64 encoded certificate data required to communicate with the EKS cluster"
  value       = aws_eks_cluster.eks.certificate_authority
}

output "aws_iam_role_name" {
  description = "The name of the IAM role associated with the EKS nodes"
  value       = aws_iam_role.nodes.name
}

output "oidc_issuer" {
  value = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}