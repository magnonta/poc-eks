# Module to create an EKS cluster using a predefined module.
# The cluster name is constructed dynamically using environment and region variables.
# The node group's capacity type, instance types, node group names, scaling config, update config, 
# and labels are all sourced from local environment variables.
module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name     = "eks-${local.env.eks.cluster.name}-${var.environment}-${var.region}"
  capacity_type    = local.env.eks.node_group.capacity_type
  instance_types   = local.env.eks.node_group.instance_types
  node_group_names = local.env.eks.node_group.node_group_names
  scaling_config   = local.env.eks.node_group.scaling_config

  update_config = local.env.eks.node_group.update_config

  labels = local.env.eks.node_group.labels

  # IAM roles and policies for the cluster and node groups are defined here.
  iam_cluster_role_name      = local.cluster_iam.cluster_iam_name
  assume_role_cluster_policy = local.cluster_iam.cluster_role
  iam_node_role_name         = local.cluster_iam.nodes_role_iam_name
  assume_role_node_policy    = local.cluster_iam.node_role

  # AWS region and VPC subnet IDs where the EKS cluster will be deployed.
  region     = var.region
  subnet_ids = local.private_subnet_ids
}

# Resource to create an OIDC (OpenID Connect) provider for the EKS cluster.
# The OIDC provider is necessary for the IAM roles to authenticate Kubernetes service accounts.
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint] # The thumbprint of the OIDC provider's certificate.
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer # The OIDC issuer URL provided by EKS.
}

# IAM role specifically for the Cluster Autoscaler. 
# This role allows the autoscaler to assume the role via the OIDC provider to interact with the EKS cluster.
resource "aws_iam_role" "eks_cluster_autoscaler_role" {
  name = "AmazonEKSClusterAutoscalerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks_oidc.arn # Specifies that this role can be assumed by the OIDC provider.
      },
      Action = "sts:AssumeRoleWithWebIdentity", # Allows assumption of this role with a web identity token.
      Condition = {
        StringEquals = {
          "${data.aws_eks_cluster.eks.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler" # Condition restricts the role to be assumed only by the specific service account in the kube-system namespace.
        }
      }
    }]
  })
}

# Attaches the necessary policy to the IAM role for the Cluster Autoscaler.
# This policy grants the required permissions for the autoscaler to scale the EKS cluster's node groups.
resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_policy_attachment" {
  policy_arn = "arn:aws:iam::019496914213:policy/AmazonEKSClusterAutoscalerPolicy" # The ARN of the policy to be attached.
  role       = aws_iam_role.eks_cluster_autoscaler_role.name # The IAM role to which the policy will be attached.
}

# Creates a Kubernetes Service Account specifically for the Cluster Autoscaler.
# This service account is annotated with the ARN of the IAM role, allowing it to assume the role.
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_cluster_autoscaler_role.arn # Annotation linking the IAM role to the service account.
    }
  }
}
