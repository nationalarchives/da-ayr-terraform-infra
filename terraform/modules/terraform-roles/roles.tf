resource "aws_iam_role" "da-ayr-terraform-role" {
  name = "ayr-da-terraform-role"

  assume_role_policy = data.aws_iam_policy_document.da_ayr_assume_role_terraform.json

ﬁ