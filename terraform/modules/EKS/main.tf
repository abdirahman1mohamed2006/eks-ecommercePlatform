resource "aws_kms_key" "eks_secrets" {
  description             = "Envelope encryption for ${var.cluster_name} Kubernetes secrets"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = var.tags
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    #trivy:ignore:AWS-0040 Public endpoint is intentional and restricted to api_allowed_cidrs
    endpoint_public_access = true
    #trivy:ignore:AWS-0041 Restricted to a single trusted /32 via api_allowed_cidrs
    public_access_cidrs = var.api_allowed_cidrs
  }

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = var.tags
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

data "aws_partition" "current" {}

locals {
  oidc_issuer = trimprefix(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_role" "ebs_csi" {
  name = "${substr(var.cluster_name, 0, 49)}-ebs-csi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "general-purpose"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = var.tags

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = var.tags

  depends_on = [
    aws_eks_node_group.this,
    aws_iam_role_policy_attachment.ebs_csi,
  ]
}

# Installs the VolumeSnapshot CRDs and the snapshot controller; the EBS CSI
# driver's csi-snapshotter sidecar then turns VolumeSnapshots into EBS snapshots.
resource "aws_eks_addon" "snapshot_controller" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "snapshot-controller"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = var.tags

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  tags                        = var.tags

  depends_on = [aws_eks_node_group.this]
}

