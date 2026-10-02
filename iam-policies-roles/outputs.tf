output "eks_pod_identity_role_arn" {
  description = "ARN of the EKS pod identity role"
  value       = aws_iam_role.eks_pod_identity_role.arn
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.cluster.arn
}

output "eks_nodegroup_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_nodegroup.arn
}

output "eks_fargate_pod_execution_role_arn" {
  description = "ARN of the EKS Fargate pod execution role"
  value       = aws_iam_role.eks_fargate_pod_execution.arn
}

output "eks_pod_identity_role_ebs_csi_arn" {
  description = "ARN of the EKS pod identity role used for EBS CSI"
  value       = aws_iam_role.eks_pod_identity_role_ebs_csi.arn
}

output "access_secret_policy_arn" {
  description = "ARN of the custom access secret IAM policy"
  value       = aws_iam_policy.access_secret_policy.arn
}

output "awspca_issuer_policy_arn" {
  description = "ARN of the custom AWS PCA Issuer IAM policy"
  value       = aws_iam_policy.awspca_issuer_policy.arn
}

output "aws_load_balancer_controller_policy_arn" {
  description = "ARN of the custom AWS Load Balancer Controller IAM policy"
  value       = aws_iam_policy.aws_load_balancer_controller_policy.arn
}

output "role_arns" {
  description = "All IAM role ARNs created in this module"
  value = {
    eks_pod_identity_role          = aws_iam_role.eks_pod_identity_role.arn
    cluster_role                   = aws_iam_role.cluster.arn
    eks_nodegroup_role             = aws_iam_role.eks_nodegroup.arn
    eks_fargate_pod_execution_role = aws_iam_role.eks_fargate_pod_execution.arn
    eks_pod_identity_role_ebs_csi  = aws_iam_role.eks_pod_identity_role_ebs_csi.arn
  }
}

output "policy_arns" {
  description = "All IAM policy ARNs created in this module"
  value = {
    access_secret_policy = aws_iam_policy.access_secret_policy.arn
    awspca_issuer_policy  = aws_iam_policy.awspca_issuer_policy.arn
    aws_load_balancer_controller_policy = aws_iam_policy.aws_load_balancer_controller_policy.arn
  }
}
