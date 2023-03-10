resource "aws_lambda_function" "lambda_role_assigner" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_bag_role_assigner.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-role-assigner-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
   handler       ="lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_role_assigner.zip")

  runtime = "python3.9"
  timeout       = 30

  environment {
    variables = {
      AYR_ROLE_MAP_PARAM_STORE_KEY = "/dev/AYR_DEPARTMENT_ROLE_MAP"
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group5" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_role_assigner.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}