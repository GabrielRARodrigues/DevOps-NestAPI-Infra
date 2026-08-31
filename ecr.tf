resource "aws_ecr_repository" "devops-nest-api" {
  name                 = "devops-nest-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    IAC = "True"
  }
}
