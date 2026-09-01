resource "aws_iam_openid_connect_provider" "oidc-github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "terraform_role" {
  name = "terraform_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = ["repo:GabrielRARodrigues@105179063/DevOps-NestAPI-Infra@1352926183:ref:refs/heads/main", "repo:GabrielRARodrigues@105179063/DevOps-NestAPI-Infra@1352926183:ref:refs/heads/main"]
        }
      }
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc-github.arn
      }
    }]
    Version = "2012-10-17"
    }
  )

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "ecr_role" {
  name = "ecr_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = ["repo:GabrielRARodrigues@105179063/DevOps-NestAPI@1321869579:ref:refs/heads/main", "repo:GabrielRARodrigues@105179063/DevOps-NestAPI@1321869579:ref:refs/heads/main"]
        }
      }
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.oidc-github.arn
      }
    }]
    Version = "2012-10-17"
    }
  )

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy" "ecr_app_permission_policy" {
  name = "ecr_app_permission_policy"
  role = aws_iam_role.ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid = "Statement1"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ]
      Effect   = "Allow"
      Resource = "*"
      },
      {
        Sid = "Statement2"
        Action = [
          "apprunner:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "Statement3"
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "app_runner_role" {
  name = "app_runner_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy_attachment" "app_runner_role_policy_attachment" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
