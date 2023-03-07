resource "aws_api_gateway_rest_api" "da-ayr" {
  name = "da-ayr-api-gateway-rest-api-private"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:eu-west-2:281072317055:p2edhc6y1d/*/*/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpce": "${aws_vpc_endpoint.da-ayr.id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:eu-west-2:281072317055:p2edhc6y1d/*/*/*"
        }
    ]
}
EOF

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.da-ayr.id]
  }
}

resource "aws_api_gateway_resource" "da-ayr" {
  rest_api_id = aws_api_gateway_rest_api.da-ayr.id
  parent_id   = aws_api_gateway_rest_api.da-ayr.root_resource_id
  path_part   = "da-ayr-dev"
}

resource "aws_api_gateway_method" "da-ayr" {
  rest_api_id   = aws_api_gateway_rest_api.da-ayr.id
  resource_id   = aws_api_gateway_resource.da-ayr.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.da-ayr-authorizer.id
}

# resource "aws_api_gateway_stage" "stage-test" {
#   deployment_id = aws_api_gateway_deployment.test.id
#   rest_api_id   = aws_api_gateway_rest_api.da-ayr-test.id
#   stage_name    = "test"
# }

resource "aws_api_gateway_integration" "test_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.da-ayr.id}"
  resource_id             = "${aws_api_gateway_resource.da-ayr.id}" 
  http_method             = "${aws_api_gateway_method.da-ayr.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
#   type                    = "MOCK"
#   uri                     = "${aws_lambda_function.lambda_rest_api.invoke_arn}"
  uri                     = "${aws_lambda_function.lambda_rest_api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.da-ayr.id
  stage_name = "test"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
        aws_api_gateway_method.da-ayr,
        aws_api_gateway_integration.test_integration
      ]
}

output "api-url" {
  value = "https://${aws_api_gateway_rest_api.da-ayr.id}-${aws_vpc_endpoint.da-ayr.id}.execute-api.eu-west-2.amazonaws.com/test"
}

resource "aws_api_gateway_authorizer" "da-ayr-authorizer" {
  name                   = "da-ayr-authorizer-dev"
  rest_api_id            = aws_api_gateway_rest_api.da-ayr.id
  authorizer_uri         = aws_lambda_function.lambda_auth.invoke_arn
  identity_source        = "method.request.header.foo"
  type                   = "TOKEN"
  authorizer_result_ttl_in_seconds = 0
  identity_validation_expression = ""
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.da-ayr.id
  resource_id = aws_api_gateway_resource.da-ayr.id
  http_method = aws_api_gateway_method.da-ayr.http_method
  status_code = "200"
}

resource "aws_api_gateway_account" "da-ayr" {
  cloudwatch_role_arn = "${aws_iam_role.cloudwatch.arn}"
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = "${aws_iam_role.cloudwatch.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_method_settings" "general_settings" {
  # rest_api_id = "${aws_api_gateway_rest_api.rest_api.id}"
  rest_api_id = "${aws_api_gateway_rest_api.da-ayr.id}"
  # stage_name  = "${aws_api_gateway_deployment.deployment_production.stage_name}"
  stage_name  = "${aws_api_gateway_deployment.test.stage_name}"
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}