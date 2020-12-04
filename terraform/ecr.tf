resource "aws_ecr_repository" "randomname" {
  name                 = var.imagename
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}