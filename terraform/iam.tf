data "aws_iam_policy_document" "lambda_role_sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "step_function_role_sts" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_access_role" {
  name               = var.lambda_function_name
  assume_role_policy = data.aws_iam_policy_document.lambda_role_sts.json
  description        = "Role for step function lambda"

  tags = var.default_tags
}

resource "aws_iam_role" "step_function_access_role" {
  name               = "step-function-access-role"
  assume_role_policy = data.aws_iam_policy_document.step_function_role_sts.json
  description        = "Role for step function"

  tags = var.default_tags
}

data "aws_iam_policy_document" "step_function_access_policy" {
  statement {
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.step_function.arn
    ]
  }
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.step_function_queue.arn
    ]
  }
}

resource "aws_iam_role_policy" "step_function_access_policy" {
  name   = "step-function-access-policy"
  role   = aws_iam_role.step_function_access_role.id
  policy = data.aws_iam_policy_document.step_function_access_policy.json
}


data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"

    ]
    resources = [
      aws_ecr_repository.randomname.arn
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [
      aws_sqs_queue.step_function_queue.arn
    ]
  }
  statement {
    actions = [
      "states:SendTaskSuccess",
      "states:SendTaskFailure"
    ]
    resources = [
      aws_sfn_state_machine.sfn_state_machine.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_access_policy" {
  name   = "lambda-access-policy"
  role   = aws_iam_role.lambda_access_role.id
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}