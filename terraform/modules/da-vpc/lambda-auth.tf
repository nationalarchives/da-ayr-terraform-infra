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
    }
  ]
}
EOF
}




resource "aws_iam_policy" "iam_for_lambda_auth_policy" {
  name = "${var.project_name}-auth-${var.environment}-policy"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:AttachNetworkInterface"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:CreateVpcEndpointServiceConfiguration",
                "ec2:ModifyVpcEndpointServicePermissions",
                "ec2:CreateVpcEndpointConnectionNotification",
                "ec2:DeleteNetworkInterfacePermission",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:CreateVpcEndpoint"
            ],
            "Resource": "*"
        }
    ]
  }
  POLICY
}


resource "aws_iam_policy_attachment" "iam_for_lambda_auth_attachment" {
  name = "${var.project_name}-auth-${var.environment}-policy-attachment"
  roles      = [aws_iam_role.iam_for_lambda_auth.name]
  policy_arn = aws_iam_policy.iam_for_lambda_auth_policy.arn
}




resource "aws_security_group" "vpc-default" {
  name        = "da-ayr-vpc-default-${var.environment}"
  description = "Allow HTTPS access to Private API Endpoimt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls_all"
  }
}


data "aws_ssm_parameter" "keycloak_realm_name_id" {
  name = "/dev/KEYCLOACK_REALM_NAME"
}
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
  handler       = "lambda_handler"
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
    # security_group_ids = [aws_security_group.vpc-endpoint.id] module.vpc.default_security_group_id
    # security_group_ids = [aws_security_group.vpc-endpoint.id]
    security_group_ids = [aws_security_group.vpc-default.id]
    

  }

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
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