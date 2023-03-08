# resource "aws_iam_role" "iam_for_lambda_rest_api" {
#   name = "${var.project_name}-rest-api-${var.environment}-role"

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
#   roles      = [aws_iam_role.iam_for_lambda_rest_api.name]
#   policy_arn = aws_iam_policy.iam_lambda_policy.arn
# }

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_rest_api" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_rest_api.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-rest-api-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
  handler       ="aws_lambda.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../../lambda/lambda_rest_api.zip")
  timeout       = 30
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
      
      OPENSEARCH_HOST_URL	= "${data.aws_ssm_parameter.master_os_host.value}"
      OPENSEARCH_USER	=  "${data.aws_ssm_parameter.master_user_name.value}"
      OPENSEARCH_USER_PASSWORD_PARAM_STORE_KEY = "/dev/OS_USER_PASSWORD"
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group7" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_rest_api.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_permission" "apigw_lambda_auth_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rest_api.function_name
  principal     = "apigateway.amazonaws.com"
  #source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/${aws_api_gateway_method.da-ayr.http_method}${aws_api_gateway_resource.da-ayr.path}"
  # source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/${aws_api_gateway_method.da-ayr.http_method}"
  source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/POST/*"

  # source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/POST/*"
  # source_arn = "arn:aws:execute-api:${var.region}:${var.aws_account_id}:*"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}