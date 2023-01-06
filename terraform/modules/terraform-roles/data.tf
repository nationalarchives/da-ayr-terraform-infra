data "aws_iam_policy_document" "da_ayr_assume_role_terraform" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
    identifiers = [var.roles_can_assume_terraform_role]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
   }
 }
}