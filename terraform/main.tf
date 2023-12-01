provider "aws" {
  region = "ap-south-1"
}

# Lambda function
resource "aws_iam_role" "cloud_cost_optimizer_lambda_role" {
  name               = "cloud-cost-optimizer-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "lambda_policy_ec2" {
  name = "lambda-policy-ec2"
  role = aws_iam_role.cloud_cost_optimizer_lambda_role.id

  policy = data.aws_iam_policy_document.lambda_role_policy_ec2.json
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "basic-execution-role"
  roles      = [aws_iam_role.cloud_cost_optimizer_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "fn_lambda" {
  filename      = "main.zip"
  function_name = "main"
  role          = aws_iam_role.cloud_cost_optimizer_lambda_role.arn
  handler       = "main.lambda_handler"

  runtime = "python3.10"
  timeout = 10
}

# Cloudwatch
resource "aws_cloudwatch_event_rule" "cloud_cost_optimizer" {
  name = "cloud-cost-optimizer-event-rule"

  schedule_expression = "cron(35 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "cloud_cost_optimizer" {
  rule      = aws_cloudwatch_event_rule.cloud_cost_optimizer.name
  arn       = aws_lambda_function.fn_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.cloud_cost_optimizer.arn
}
