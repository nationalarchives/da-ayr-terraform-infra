 resource "aws_ecr_repository" "ecr" {
   name                 = "${var.project_name}-django_app-${var.environment}"
   image_tag_mutability = "MUTABLE"
   
   image_scanning_configuration {
     scan_on_push = true
   }
 }