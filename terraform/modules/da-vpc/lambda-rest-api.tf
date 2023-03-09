resource "aws_lambda_function" "lambda_rest_api" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_rest_api.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-rest-api-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
  handler       ="aws_lambda.lambda_handler"

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
  # source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/${aws_api_gateway_method.da-ayr.http_method}"
  source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/POST/*"
}