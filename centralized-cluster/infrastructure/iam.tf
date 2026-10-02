resource "aws_iam_role" "aws_load_balancer_controller_platform_irsa" {
  name = "aws-load-balancer-controller-platform-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_platform_irsa_policy_attachment" {
  policy_arn = "arn:aws:iam::829007908826:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = aws_iam_role.aws_load_balancer_controller_platform_irsa.name
}

resource "aws_iam_role" "xray_daemon_platform_irsa" {
  name = "xray-daemon-platform-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub" = "system:serviceaccount:default:xray-daemon"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xray_daemon_irsa_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.xray_daemon_platform_irsa.name
}
# Note: iam_policy.json = https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json

data "aws_iam_policy_document" "pca_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:aws-pca-issuer:aws-pca-issuer"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pca_issuer" {
  name               = "ServiceAccountRolePrivateCA-platform-cluster"
  assume_role_policy = data.aws_iam_policy_document.pca_assume_role.json
}

resource "aws_iam_role_policy_attachment" "pca_issuer" {
  role       = aws_iam_role.pca_issuer.name
  policy_arn = "arn:aws:iam::829007908826:policy/AWSPCAIssuerPolicy"
}