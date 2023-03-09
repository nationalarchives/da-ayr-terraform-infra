

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_auth" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_auth.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-auth-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 30
  runtime       = "python3.8"

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    # subnet_ids         = [module.vpc.private_subnets]
    subnet_ids = [
            module.vpc.private_subnets[0],
            module.vpc.private_subnets[1],
            module.vpc.private_subnets[2]
    ]

    security_group_ids = [aws_security_group.vpc-default.id]
    

  }

  source_code_hash = filebase64sha256("../../../lambda/lambda_auth.zip")

  environment {
    variables = {
      KEYCLOAK_CLIENT_ID = "${data.aws_ssm_parameter.keycloak_client_id.value}"
      KEYCLOAK_HOST = "${data.aws_ssm_parameter.keycloak_hostname.value}"
      KEYCLOAK_REALM = "${data.aws_ssm_parameter.keycloak_realm_name_id.value}" #defined in ec2-fargate
      PARAM_STORE_KEY_KEYCLOAK_CLIENT_SECRET = "/dev/KEYCLOAK_ID_CLIENT_SECRET"
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group1" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_auth.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
