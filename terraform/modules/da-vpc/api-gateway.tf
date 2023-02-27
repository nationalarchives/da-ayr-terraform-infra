resource "aws_api_gateway_rest_api" "da-ayr-test" {
  name = "Private-API"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ],
            "Condition" : {
                "StringNotEquals": {
                    "aws:SourceVpce": "${aws_vpc_endpoint.da-ayr.id}"
                }
            }
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
  rest_api_id = aws_api_gateway_rest_api.da-ayr-test.id
  parent_id   = aws_api_gateway_rest_api.da-ayr-test.root_resource_id
  path_part   = "da-ayr-test"
}

resource "aws_api_gateway_method" "da-ayr" {
  rest_api_id   = aws_api_gateway_rest_api.da-ayr-test.id
  resource_id   = aws_api_gateway_resource.da-ayr.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "stage-test" {
  deployment_id = aws_api_gateway_deployment.test.id
  rest_api_id   = aws_api_gateway_rest_api.da-ayr-test.id
  stage_name    = "test"
}

resource "aws_api_gateway_integration" "test_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.da-ayr-test.id}"
  resource_id             = "${aws_api_gateway_resource.da-ayr.id}"
  http_method             = "${aws_api_gateway_method.da-ayr.http_method}"
  integration_http_method = "GET"
  type                    = "AWS"
#   uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-2:281072317055:function:dgandy-tmp-test-lambda-1/invocations"
  uri                     = "${aws_lambda_function.lambda_rest_api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "test" {
  rest_api_id = aws_api_gateway_rest_api.da-ayr-test.id
  stage_name = "test"

  depends_on = [
        aws_api_gateway_method.da-ayr,
        aws_api_gateway_integration.test_integration
      ]
}

output "api-url" {
  value = "https://${aws_api_gateway_rest_api.da-ayr-test.id}-${aws_vpc_endpoint.da-ayr.id}.execute-api.eu-west-2.amazonaws.com/test"
}



