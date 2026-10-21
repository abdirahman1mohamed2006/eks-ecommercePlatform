
resource "aws_s3_bucket" "tf_state" {
  bucket = var.tf_state_bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint
  ]

  tags = var.tags
}

resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}",
            "repo:${var.github_owner}@*/${var.github_repository}@*:ref:refs/heads/${var.github_branch}",
          ]
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = var.github_actions_policy_arns

  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = each.value
}

resource "aws_iam_policy" "github_actions_terraform" {
  name        = "github-actions-terraform"
  description = "Permissions for the GitHub Actions role to plan and apply the EKS platform Terraform."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "PlatformServices"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "eks:*",
          "ecr:*",
          "sqs:*",
          "kms:*",
          "logs:*",
          "iam:*",
          "route53:*",
          "elasticloadbalancing:*",
          "autoscaling:Describe*",
          "sts:GetCallerIdentity",
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          aws_s3_bucket.tf_state.arn,
          "${aws_s3_bucket.tf_state.arn}/*",
        ]
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}