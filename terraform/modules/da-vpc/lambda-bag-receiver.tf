# resource "aws_iam_role" "iam_for_lambda_receiver" {
#   name = "${var.project_name}-receiver-${var.environment}-role"

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
#   roles      = [aws_iam_role.iam_for_lambda_receiver.name]
#   policy_arn = aws_iam_policy.iam_lambda_policy.arn
# }

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_receiver" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_bag_receiver.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-receiver-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
   handler       ="lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_receiver.zip")

  runtime = "python3.9"

  environment {
    variables = {
      ENV_OPENSEARCH_HOST_URL = ""
      ENV_OPENSEARCH_USER = ""
      ENV_OPENSEARCH_USER_PASSWORD = ""
    }
  }
}