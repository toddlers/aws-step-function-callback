output "step_function_arn" {
  description = "ARN of the step function state machine"
  value = aws_sfn_state_machine.sfn_state_machine.arn
}
