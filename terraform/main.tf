locals {
  tags = {
    Project     = "eks-v2"
    Environment = "sandbox"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "./modules/VPC"
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "eks_nodes" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])

  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

module "eks" {
  source = "./modules/EKS"

  cluster_name              = var.cluster_name
  api_allowed_cidrs         = var.api_allowed_cidrs
  cluster_role_arn          = aws_iam_role.eks_cluster.arn
  node_group_role_arn       = aws_iam_role.eks_nodes.arn
  private_subnet_ids        = module.vpc.private_subnet_ids
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  node_group_instance_types = var.node_group_instance_types
  tags                      = local.tags
}

module "sqs" {
  source     = "./modules/SQS"
  queue_name = var.sqs_queue_name
  tags       = local.tags
}

module "route53" {
  source    = "./modules/Route53"
  zone_name = var.route53_zone_name
}

module "iam" {
  source = "./modules/IAM"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url

  worker_namespace                   = var.kubernetes_namespace
  worker_service_account_name        = "${var.helm_release_name}-worker"
  worker_sqs_queue_arns              = [module.sqs.queue_arn]
  order_service_namespace            = var.kubernetes_namespace
  order_service_service_account_name = "${var.helm_release_name}-order-service"
  order_service_sqs_queue_arns       = [module.sqs.queue_arn]
  payments_namespace                 = var.kubernetes_namespace
  payments_service_account_name      = "${var.helm_release_name}-payment-service"
  payments_sqs_queue_arns            = [module.sqs.queue_arn]
  shipping_namespace                 = var.kubernetes_namespace
  shipping_service_account_name      = "${var.helm_release_name}-shipping-service"
  shipping_sqs_queue_arns            = [module.sqs.queue_arn]
  route53_hosted_zone_arns           = module.route53.zone_arns
  tags                               = local.tags
}

module "ecr" {
  for_each = var.service_names
  source   = "./modules/ECR"

  repository_name = each.value
  tags            = local.tags
}
