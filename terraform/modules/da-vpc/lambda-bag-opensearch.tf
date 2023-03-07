# resource "aws_iam_role" "iam_for_lambda_opensearch" {
#   name = "${var.project_name}-opensearch-${var.environment}-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy_attachment" "iam_for_lambda_auth_attachment" {
#   name = "${var.project_name}-auth-${var.environment}-policy-attachment"
#   roles      = [aws_iam_role.iam_for_lambda_opensearch.name]
#   policy_arn = aws_iam_policy.iam_lambda_policy.arn
# }

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_opensearch" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_bag_to_opensearch.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-opensearch-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
  handler       ="lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_to_opensearch.zip")

  runtime = "python3.9"

  vpc_config {
    subnet_ids = [
            module.vpc.private_subnets[0],
            module.vpc.private_subnets[1],
            module.vpc.private_subnets[2]
    ]
    security_group_ids = [aws_security_group.vpc-default.id]
    

  }

  environment {
    variables = {
      OPENSEARCH_HOST_URL	= "https://vpc-da-ayr-aws-opensearch-dev-bij2z45raruw42t755inwpjw7u.eu-west-2.es.amazonaws.com"
      OPENSEARCH_INDEX	= "${data.aws_ssm_parameter.master_os_index.value}"
      OPENSEARCH_USER	= "${data.aws_ssm_parameter.master_user_name.value}"
      OPENSEARCH_USER_PASSWORD_PARAM_STORE_KEY =	"/${var.environment}/OS_USER_PASSWORD"
    }
  }
}