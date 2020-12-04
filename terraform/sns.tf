resource "aws_sns_topic" "step_function" {
  name = "step-function-callback-topic"
}