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
            "Resource": "arn:aws:execute-api:eu-west-2:281072317055:"${aws_api_gateway_rest_api.da-ayr.id}"/*/*/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpc": "${aws_vpc_endpoint.da-ayr.id}"
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
  path_part   = "da-ayr-test"
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
#   type                    = "AWS_PROXY"
  type                    = "REST"
#   uri                     = "${aws_lambda_function.lambda_rest_api.invoke_arn}"
  uri                     = "${aws_lambda_function.lambda_auth.invoke_arn}"
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
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
  authorizer_result_ttl_in_seconds = 300
  identity_validation_expression = ""
}



