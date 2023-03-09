# Create IAM role for AWS Step Function
resource "aws_iam_role" "iam_da_ayr_stepfunction" {
  name = "stepFunctionSampleStepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# resource "aws_iam_policy" "policy_publish_sns" {
#   name        = "stepFunctionSampleSNSInvocationPolicy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "VisualEditor0",
#             "Effect": "Allow",
#             "Action": [
#               "sns:Publish",
#               "sns:SetSMSAttributes",
#               "sns:GetSMSAttributes"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }


resource "aws_iam_policy" "policy_da_ayr_stepfunction" {
  name        = "stepFunctionSampleLambdaFunctionInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


// Attach policy to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_stepfunction_da_ayr_invoke_lambda" {
  role       = "${aws_iam_role.iam_da_ayr_stepfunction.name}"
  policy_arn = "${aws_iam_policy.policy_da_ayr_stepfunction.arn}"
}

# resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
#   role       = "${aws_iam_role.iam_for_sfn.name}"
#   policy_arn = "${aws_iam_policy.policy_publish_sns.arn}"
# }



// Create state machine for step function
resource "aws_sfn_state_machine" "sfn_da_ayr_state_machine" {
  name     = "Ingester-da-ayr-alpha"
  role_arn = "${aws_iam_role.iam_da_ayr_stepfunction.arn}"

  definition = <<EOF
{
  "StartAt": "Save Bag from TRE Event (pre-signed URL)",
  "States": {
    "Save Bag from TRE Event (pre-signed URL)": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:281072317055:function:da-ayr-auth-dev"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Unpack Bag"
    },
    "Unpack Bag": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:281072317055:function:da-ayr-unpacker-dev"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Prepare OpenSearch Record"
    },
    "Prepare OpenSearch Record": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:281072317055:function:da-ayr-indexer-dev"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Add AYR Role to OpenSearch Record"
    },
    "Add AYR Role to OpenSearch Record": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:281072317055:function:da-ayr-role-assigner-dev"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "Insert OpenSearch Record"
    },
    "Insert OpenSearch Record": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:281072317055:function:da-ayr-opensearch-dev"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  },
  "Comment": "Adds an OpenSearch Bag record with an ayr_role key set according to the Bag's department (i.e. Source-Organization). The mapping of Bag departments to AYR roles is configured in Parameter Store."
}

EOF

  depends_on = ["aws_lambda_function.random-number-generator-lambda","aws_lambda_function.random-number-generator-lambda"]

}