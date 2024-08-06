# Retrieves a list of available availability zones in the current AWS region.
data "aws_availability_zones" "available" {
  state = "available" # Only includes availability zones that are currently available.
}

# Retrieves a list of public subnets within the specified VPC and availability zones.
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name" 
    values = ["public-subnet-*"]
  }

  filter {
    name   = "vpc-id" 
    values = [aws_vpc.vpc.id]
  }

  filter {
    name   = "availability-zone" 
    values = local.supported_azs
  }
}

# Retrieves a list of private subnets within the specified VPC and availability zones.
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name" 
    values = ["private-subnet-*"]
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  filter {
    name   = "availability-zone" 
    values = local.supported_azs
  }
}

# Retrieves authentication credentials for the specified EKS cluster.
data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_name 
}

# Retrieves detailed information about the specified EKS cluster.
data "aws_eks_cluster" "eks" {
  name = module.eks_cluster.eks_cluster_name 
}

# Retrieves the TLS certificate from the OIDC issuer URL of the EKS cluster.
data "tls_certificate" "cert" {
  url = module.eks_cluster.oidc_issuer
}
