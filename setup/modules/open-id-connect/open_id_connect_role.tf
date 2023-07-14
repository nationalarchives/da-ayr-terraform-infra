resource "aws_iam_role" "da_ayr_github_actions_open_id_connect" {
  #for_each           = { for role in var.da_ayr_github_actions_open_id_connect_roles : role.name => role }
  name               = "${var.prefix}-github-actions-open-id-connect-roles"
  assume_role_policy = data.aws_iam_policy_document.da_ayr_github_actions_open_id_connect.json
}

data "aws_iam_policy_document" "da_ayr_github_actions_open_id_connect" {
  #for_each = { for role in var.da_ayr_github_actions_open_id_connect_roles : role.name => role }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.da_ayr_github_actions.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.da_ayr_repositories
    }
  }
}

resource "aws_iam_policy" "da_ayr_github_actions_open_id_connect" {
  #for_each = { for policy in var.da_ayr_actions_open_id_connect_policies : policy.name => policy }
  name = "${var.prefix}-github-actions-open-id-connect-role-"
  policy = templatefile("${path.module}/templates/open_id_connect_role_policy.tftpl", {
    account_id      = var.account_id
    terraform_roles = var.terraform_roles
  })
}

resource "aws_iam_role_policy_attachment" "da_ayr_github_actions_open_id_connect" {
  #for_each   = { for role in var.da_ayr_github_actions_open_id_connect_roles : role.name => role }
  role       = aws_iam_role.da_ayr_github_actions_open_id_connect.name
  policy_arn = aws_iam_policy.da_ayr_github_actions_open_id_connect.arn
}
