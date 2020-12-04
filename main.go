package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sfn"
)

// MessageBody contains message from aws step function with token
type MessageBody struct {
	MessageTitle string `json:"MessageTitle"`
	TaskToken    string `json:"TaskToken"`
}

//HandleRequest main lambda handler
func HandleRequest(ctx context.Context, sqsEvent events.SQSEvent) error {
	log.Println("The event received")
	log.Println(sqsEvent)
	var messageBody MessageBody
	client := sfn.New(session.Must(session.NewSession()))
	for _, message := range sqsEvent.Records {
		json.Unmarshal([]byte(message.Body), &messageBody)
		messageTitle, _ := json.Marshal(messageBody.MessageTitle)
		params := &sfn.SendTaskSuccessInput{
			Output:    aws.String(string(messageTitle)),
			TaskToken: aws.String(messageBody.TaskToken),
		}
		_, err := client.SendTaskSuccess(params)

		if err != nil {
			return err
		}

	}
	return nil
}

func main() {
	lambda.Start(HandleRequest)
}
