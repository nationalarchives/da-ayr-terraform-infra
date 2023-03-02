resource "aws_iam_role" "iam_for_lambda_auth" {
  name = "${var.project_name}-auth-${var.environment}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:eu-west-2:281072317055:*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:eu-west-2:281072317055:log-group:/aws/lambda/*:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },
    {
      "Sid": "GetParameter",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:eu-west-2:281072317055:parameter/dev/*"
    },
    {
      "Sid": "DecryptKey",
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "arn:aws:ssm:eu-west-2:281072317055:parameter/dev/*"
    }
  ]
}
EOF
}
# Defined in fargate
# data "aws_ssm_parameter" "keycloak_realm_name" {
#   name = "/dev/KEYCLOACK_REALM_NAME"
# }
data "aws_ssm_parameter" "keycloak_hostname" {
  name = "/dev/KC_HOSTNAME"
}
data "aws_ssm_parameter" "keycloak_client_id" {
  name = "/dev/KEYCLOAK_CLIENT_ID"
}
# data "aws_ssm_parameter" "keycloak_client_secret" {
#   name = "/dev/KEYCLOAK_ID_CLIENT_SECRET"
# }

# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_auth" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_auth.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-auth-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_auth.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 30

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [module.vpc.private_subnets]
    # security_group_ids = [aws_security_group.vpc-endpoint.id] module.vpc.default_security_group_id
    security_group_ids = [aws_security_group.vpc-endpoint.id]

  }

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../../lambda/lambda_auth.zip")

  runtime = "python3.9"

  environment {
    variables = {
      KEYCLOAK_CLIENT_ID = "${data.aws_ssm_parameter.keycloak_client_id.value}"
      KEYCLOAK_HOST = "${data.aws_ssm_parameter.keycloak_hostname.value}"
      KEYCLOAK_REALM = "${data.aws_ssm_parameter.keycloak_realm_name.value}"
      PARAM_STORE_KEY_KEYCLOAK_CLIENT_SECRET = "/dev/KEYCLOAK_ID_CLIENT_SECRET"
    }
  }
}


# resource "aws_lambda_permission" "apigw_lambda_auth_permission" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda_auth.function_name
#   principal     = "apigateway.amazonaws.com"
#   #source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/${aws_api_gateway_method.da-ayr.http_method}${aws_api_gateway_resource.da-ayr.path}"
#   source_arn    = "arn:aws:execute-api:eu-west-2:${var.aws_account_id}:${aws_api_gateway_rest_api.da-ayr.id}/*/${aws_api_gateway_method.da-ayr.http_method}"
#   # source_arn = "arn:aws:execute-api:${var.region}:${var.aws_account_id}:*"
#   # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
#   # source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
# }