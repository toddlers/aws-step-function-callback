resource "aws_sqs_queue" "step_function_queue_deadletter" {
  name                      = "step-function-dl-queue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = var.default_tags
}

resource "aws_sqs_queue" "step_function_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.step_function_queue_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = var.default_tags
}