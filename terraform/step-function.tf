
data "aws_region" "current" {}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.step_function_access_role.arn

  definition = <<EOF
{
    "Comment": "An example of the Amazon States Language for starting a task and waiting for a callback.",
    "StartAt": "Start Task And Wait For Callback",
    "States": {
    "Start Task And Wait For Callback": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sqs:sendMessage.waitForTaskToken",
        "Parameters": {
        "QueueUrl": "${aws_sqs_queue.step_function_queue.id}",
        "MessageBody": {
            "MessageTitle": "Task started by Step Functions. Waiting for callback with task token.",
            "TaskToken.$": "$$.Task.Token"
        }
        },
        "Next": "Notify Success",
        "Catch": [
        {
        "ErrorEquals": [ "States.ALL" ],
        "Next": "Notify Failure"
        }
        ]
    },
    "Notify Success": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sns:publish",
        "Parameters": {
        "Message": "Callback received. Task started by Step Functions succeeded.",
        "TopicArn": "${aws_sns_topic.step_function.arn}"
        },
        "End": true
    },
    "Notify Failure": {
        "Type": "Task",
        "Resource": "arn:aws:states:::sns:publish",
        "Parameters": {
        "Message": "Task started by Step Functions failed.",
        "TopicArn": "${aws_sns_topic.step_function.arn}"
        },
        "End": true
    }
    }
}
EOF
}