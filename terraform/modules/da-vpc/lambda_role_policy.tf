resource "aws_security_group" "vpc-default" {
  name        = "da-ayr-vpc-default-${var.environment}"
  description = "Allow HTTPS access to Private API Endpoimt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Alpha"
  }
}

#Create log group

resource "aws_iam_role" "iam_for_lambda_role" {
  name = "${var.project_name}-lambda-${var.environment}-role"

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



resource "aws_iam_policy" "iam_lambda_policy" {
  name   = "${var.project_name}-l-${var.environment}-policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
      "Resource": "*"
    },
    {
      "Action": [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:eu-west-2:281072317055:parameter/${var.environment}/*"
    },
    {
       "Effect": "Allow",
       "Action": "ssm:GetParameter",
       "Resource": "arn:aws:ssm:eu-west-2:281072317055:parameter/${var.environment}/*"
    },
    {
        "Effect": "Allow",
        "Action": "kms:Decrypt",
        "Resource": "arn:aws:ssm:eu-west-2:281072317055:parameter/${var.environment}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "s3-object-lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Action": "s3-object-lambda:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "iam_for_lambda_policy_attachment" {
  name       = "${var.project_name}-lambda-${var.environment}-policy-attachment"
  roles      = [aws_iam_role.iam_for_lambda_role.name]
  policy_arn = aws_iam_policy.iam_lambda_policy.arn
}
