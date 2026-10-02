resource "kubernetes_namespace_v1" "default_ns" {
  metadata {
    name = "default"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    aws_eks_cluster.platform_cluster
  ]
}

resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller_platform_irsa.arn
    }
  }

  depends_on = [
    aws_eks_cluster.platform_cluster,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_platform_irsa_policy_attachment
  ]
}

resource "kubernetes_namespace_v1" "istio_system_ns" {
  metadata {
    name = "istio-system"
    labels = {
      "topology.istio.io/network" = "platform-vpc"
      "topology.istio.io/cluster" = "platform-cluster"
    }
  }

  depends_on = [
    aws_eks_cluster.platform_cluster
  ]
}

resource "kubernetes_namespace_v1" "aws-pca-issuer" {
  metadata {
    name = "aws-pca-issuer"
    labels = {
      "component" = "istio-cert-manager"
      "usage" = "aws-pca-issuer"
    }
  }

  depends_on = [
    aws_eks_cluster.platform_cluster
  ]
}