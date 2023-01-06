data "aws_caller_identity" "nonprod" {
  provider = aws.nonprod
}

data "aws_caller_identity" "managment" {
  provider = aws
}

data "aws_iam_policy_document" "da_ayr_terraform_backend" {
  statement {
    effect    = "Allow"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

