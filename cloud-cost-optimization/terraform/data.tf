# Lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_role_policy_ec2" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:DescribeInstances", "ec2:DescribeVolumes", "ec2:DescribeSnapshots"]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:ec2:*::snapshot/*"]
    actions = ["ec2:DeleteSnapshot"]
  }
}