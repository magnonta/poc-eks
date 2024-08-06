resource "aws_iam_role" "eks" {
  name               = var.iam_cluster_role_name
  assume_role_policy = var.assume_role_cluster_policy
}

resource "aws_iam_role" "nodes" {
  name = var.iam_node_role_name

  assume_role_policy = var.assume_role_node_policy
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}


resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy]
}


resource "aws_eks_node_group" "private-nodes" {
  for_each        = { for name in var.node_group_names : name => name }
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-${each.key}-node-group"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.subnet_ids

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  dynamic "scaling_config" {
    for_each = var.scaling_config != null ? [var.scaling_config] : []
    content {
      desired_size = scaling_config.value.desired_size
      max_size     = scaling_config.value.max_size
      min_size     = scaling_config.value.min_size
    }
  }

  dynamic "update_config" {
    for_each = var.update_config != null ? [var.update_config] : []
    content {
      max_unavailable = update_config.value.max_unavailable
    }
  }

  labels = var.labels

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}