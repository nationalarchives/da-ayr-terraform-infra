# resource "aws_iam_role" "iam_for_lambda_role_assigner" {
#   name = "${var.project_name}-role-assigner-${var.environment}-role"

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
#   roles      = [aws_iam_role.iam_for_lambda_role_assigner.name]
#   policy_arn = aws_iam_policy.iam_lambda_policy.arn
# }

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_role_assigner" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_bag_role_assigner.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-role-assigner-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
   handler       ="lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_role_assigner.zip")

  runtime = "python3.9"
  timeout       = 30

  environment {
    variables = {
      AYR_ROLE_MAP_PARAM_STORE_KEY = "/dg-zaizi/tmp/ayr-department-role-map"
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group5" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_role_assigner.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}