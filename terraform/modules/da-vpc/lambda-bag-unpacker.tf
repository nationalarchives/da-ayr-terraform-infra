resource "aws_lambda_function" "lambda_unpacker" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename = "../../../lambda/lambda_bag_unpacker.zip"
  # function_name = "lambda_handler"
  function_name = "${var.project_name}-unpacker-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_unpacker.zip")
  timeout          = 30
  runtime          = "python3.9"
}

resource "aws_cloudwatch_log_group" "function_log_group6" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_unpacker.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
