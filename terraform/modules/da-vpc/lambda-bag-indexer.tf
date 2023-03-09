
# resource "aws_lambda_function" "test_lambda" {
resource "aws_lambda_function" "lambda_indexer" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "../../../lambda/lambda_bag_indexer.zip"
  function_name = "${var.project_name}-indexer-${var.environment}"
  role          = aws_iam_role.iam_for_lambda_role.arn 
  handler       ="lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../../../lambda/lambda_bag_indexer.zip")
  timeout       = 30
  runtime = "python3.9"

  environment {
    variables = {
      ENV_OPENSEARCH_HOST_URL = ""
      ENV_OPENSEARCH_USER = ""
      ENV_OPENSEARCH_USER_PASSWORD = ""
    }
  }
}

resource "aws_cloudwatch_log_group" "function_log_group2" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_indexer.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}