 resource "aws_ecr_repository" "ecr" {
   name                 = "${var.project_name}-django_app-${var.environment}"
   image_tag_mutability = "MUTABLE"
  
   image_scanning_configuration {
     scan_on_push = true
   }
 }

 resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPushPull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.managment_id}:role/da_ayr-github-actions-open-id-connect-roles"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage"
            ]
        }
    ]
}
EOF
}




resource "aws_ecr_repository" "ecr_keycloak" {
   name                 = "${var.project_name}-keycloak-${var.environment}"
   image_tag_mutability = "MUTABLE"
  
   image_scanning_configuration {
     scan_on_push = true
   }
 }

 resource "aws_ecr_repository_policy" "ecr_keycloak_policy" {
  repository = aws_ecr_repository.ecr_keycloak.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPushPull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.managment_id}:role/da_ayr-github-actions-open-id-connect-roles"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage"
            ]
        }
    ]
}
EOF
}

