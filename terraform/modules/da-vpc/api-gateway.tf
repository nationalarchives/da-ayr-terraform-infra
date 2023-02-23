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
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_deployment" "test" {
  rest_api_id = "${aws_api_gateway_rest_api.da-ayr-test.id}"
  stage_name = "test"
  depends_on = [
        aws_api_gateway_method.da-ayr
      ]
}


output "api-url" {
  value = "https://${aws_api_gateway_rest_api.da-ayr-test.id}-${aws_vpc_endpoint.da-ayr.id}.execute-api.eu-west-2.amazonaws.com/test"
}



