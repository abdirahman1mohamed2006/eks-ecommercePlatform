locals {
  oidc_issuer = trimprefix(var.oidc_issuer_url, "https://")
}


# IAM role and policy for the worker workload using IRSA

resource "aws_iam_role" "worker_workload" {
  name = "${var.cluster_name}-worker-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.worker_namespace}:${var.worker_service_account_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "worker_sqs" {
  name        = "${var.cluster_name}-worker-sqs-policy"
  description = "Lets the worker workload consume messages from the SQS queue."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "ConsumeQueue"
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:ChangeMessageVisibility",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = var.worker_sqs_queue_arns
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_sqs" {
  role       = aws_iam_role.worker_workload.name
  policy_arn = aws_iam_policy.worker_sqs.arn
}

# IAM role and policy for the order service workload using IRSA

resource "aws_iam_role" "order_service_workload" {
  name = "${var.cluster_name}-order-service-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.order_service_namespace}:${var.order_service_service_account_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "order_service_sqs" {
  name        = "${var.cluster_name}-order-service-sqs-policy"
  description = "Lets the order service send messages to the SQS queue."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "SendToQueue"
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = var.order_service_sqs_queue_arns
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "order_service_sqs" {
  role       = aws_iam_role.order_service_workload.name
  policy_arn = aws_iam_policy.order_service_sqs.arn
}

# IAM role and policy for the payments service workload using IRSA

resource "aws_iam_role" "payments_workload" {
  name = "${var.cluster_name}-payments-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.payments_namespace}:${var.payments_service_account_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "payments_sqs" {
  name        = "${var.cluster_name}-payments-sqs-policy"
  description = "Lets the payments service send messages to the SQS queue."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "SendToQueue"
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = var.payments_sqs_queue_arns
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "payments_sqs" {
  role       = aws_iam_role.payments_workload.name
  policy_arn = aws_iam_policy.payments_sqs.arn
}

# IAM role and policy for the shipping service workload using IRSA

resource "aws_iam_role" "shipping_workload" {
  name = "${var.cluster_name}-shipping-workload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.shipping_namespace}:${var.shipping_service_account_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "shipping_sqs" {
  name        = "${var.cluster_name}-shipping-sqs-policy"
  description = "Lets the shipping service send messages to the SQS queue."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "SendToQueue"
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Resource = var.shipping_sqs_queue_arns
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "shipping_sqs" {
  role       = aws_iam_role.shipping_workload.name
  policy_arn = aws_iam_policy.shipping_sqs.arn
}

# IAM role and policy for cert-manager (Route53 DNS-01 challenges) using IRSA

resource "aws_iam_role" "cert_manager_role" {
  name = var.cert_manager_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.cert_manager_service_account_namespace}:${var.cert_manager_service_account_name}"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "cert_manager_policy" {
  name = "${var.cluster_name}-cert-manager-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZonesByName"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:GetChange"]
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = var.route53_hosted_zone_arns
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cert_manager_attach" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}

# IAM role and policy for external-dns (Route53 record management) using IRSA

resource "aws_iam_role" "external_dns_role" {
  name = var.external_dns_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:${var.external_dns_service_account_namespace}:${var.external_dns_service_account_name}"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "external_dns_policy" {
  name = "${var.cluster_name}-external-dns-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = var.route53_hosted_zone_arns
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

