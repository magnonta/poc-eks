locals {
  env = local.environments[var.environment][var.region]

  testing_us_east_1_yaml = file(".${path.module}/environment/testing/test-us-east-1.yaml")
  # testing_us_east_2_yaml = file(".${path.module}/environment/testing/test-us-east-2.yaml")

  environments = {
    dev = {
      us-east-1 = yamldecode(local.testing_us_east_1_yaml)
    }
    # prod = {
    #   us-east-1 = yamldecode(local.testing_us_east_1_yaml)
    #   us-east-2 = yamldecode(local.testing_us_east_2_yaml)
    # }
  }

  private_subnet_ids = [for subnet in data.aws_subnets.private.ids : subnet]

  public_subnet_ids = [for subnet in data.aws_subnets.public.ids : subnet]

  supported_azs = [for az in data.aws_availability_zones.available.names : az if az != "us-east-1e"]

  cluster_iam = {
    cluster_iam_name    = "${local.env.eks.cluster.name}-${var.environment}-${var.region}"
    cluster_role        = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    POLICY
    nodes_role_iam_name = "nodes-${local.env.eks.cluster.name}-${var.environment}-${var.region}"
    node_role = jsonencode({
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }]
      Version = "2012-10-17"
    })
    autoscaler = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "autoscaling:DescribeTags",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:GetInstanceTypesFromInstanceRequirements",
            "eks:DescribeNodegroup"
          ]
          Resource = "*"
        }
      ]
    })
    # assume_role_policy = jsonencode({
    #   Version = "2012-10-17",
    #   Statement = [
    #     {
    #       Effect = "Allow",
    #       Principal = {
    #         Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
    #       },
    #       Action = "sts:AssumeRoleWithWebIdentity",
    #       Condition = {
    #         StringEquals = {
    #           "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:${var.service_account_name}"
    #         }
    #       }
    #     }
    #   ]
    # })
  }
}