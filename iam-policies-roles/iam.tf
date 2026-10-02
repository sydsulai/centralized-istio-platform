# IAM role for EKS Pod Identity with S3 full access
resource "aws_iam_role" "eks_pod_identity_role" {
  name = "eks-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = var.eks_pod_identity_role_action
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "829007908826"
          }
          ArnEquals = {
            "aws:SourceArn" = [
              "arn:aws:eks:ap-south-1:829007908826:cluster/app-cluster-01",
              "arn:aws:eks:ap-south-1:829007908826:cluster/platform-cluster"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "EKS Pod Identity Role"
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "eks_nodegroup" {
  name = "cluster-ng-private1-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "eks_fargate_pod_execution" {
  name = "cluster-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Secrets Manager read access policy to the role
resource "aws_iam_policy" "access_secret_policy" {
  name = "access-secret-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.access_secret_policy_actions
        Resource = ["arn:aws:secretsmanager:ap-south-1:829007908826:secret:*"]
      }
    ]
  })
}

# Attach S3 full access policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.eks_pod_identity_role.name
}

resource "aws_iam_role_policy_attachment" "access_secret_policy_attachment" {
  policy_arn = aws_iam_policy.access_secret_policy.arn
  role       = aws_iam_role.eks_pod_identity_role.name
}

resource "aws_iam_role" "eks_pod_identity_role_ebs_csi" {
  name = "eks-pod-identity-role-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = var.eks_pod_identity_role_action
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "829007908826"
          }
          ArnEquals = {
            "aws:SourceArn" = [
              "arn:aws:eks:ap-south-1:829007908826:cluster/app-cluster-01",
              "arn:aws:eks:ap-south-1:829007908826:cluster/platform-cluster"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "EKS Pod Identity Role"
  }
}

# Attach EBS CSI Driver policy to the role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_pod_identity_role_ebs_csi.name
}

# Attach EKS Cluster policy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_pod_execution.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_ecr_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_asg_access" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_full_ecr_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.eks_nodegroup.name
}

# resource "aws_iam_role_policy_attachment" "eks_nodegroup_appmesh_access" {
#     policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
#     role       = aws_iam_role.eks_nodegroup.name
# }

resource "aws_iam_role_policy_attachment" "eks_nodegroup_external_dns_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "ebs_csi_ec2_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.eks_pod_identity_role_ebs_csi.name
}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_alb_ingress_access" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
  role       = aws_iam_role.eks_nodegroup.name
}
# Note: iam_policy.json = https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json

resource "aws_iam_policy" "awspca_issuer_policy" {
  name   = "AWSPCAIssuerPolicy"
  policy = file("AWSPCAIssuerPolicy.json") # Update the resource in the json file.
}