# aws-step-function-callback


* An aws step function callback scenario with automation to deploy and iterate as we want.

* Deploys the following things:
  * An ECR(EC2 container repository)
  * SQS Queue
  * SNS Topic
  * AWS Step Function with callback pattern
  * Lambda function for getting a sample work done and informing back to Step Function. Lambda is deployed via the `container` image pattern which is 
  newly launched by AWS[1]
  
* Deploying the lambda via the `Makefile` , don't want to create a spaghetti with `null_resource` in terraform as I am creating the ECR in the same terraform code 
and `lambda` can't be created without the image in place. So create `ECR`, build/push image and eventually create lambda with the same image. Added benefit of that is if we want to update the image separately , we can do by calling the `make` target `update-function`.

## Workflow
This sample project demonstrates how to have AWS Step Functions pause during a task, and wait for an external process to return a task token that was generated when the task started.

The workflow is captured in the following state machine:

![Callback Workflow](https://raw.githubusercontent.com/toddlers/aws-step-function-callback/main/callback-success.png)


## Prerequisites
- AWS credentials profile and default region set locally
- Latest AWS CLI[2]
- Terraform 
```
Terraform v0.14.0
+ provider registry.terraform.io/hashicorp/aws v3.20.0
```
- Go 1.12+: [Installing Go](https://golang.org/doc/install). GOPATH configuration is required: [Setting GOPATH environment variable](https://github.com/golang/go/wiki/SettingGOPATH)

#### Testing locally

To build you image:
```
docker build -t <image name> .
```
To run your image locally:
```
docker run -p 9000:8080 <image name>
```
In a separate terminal, you can then locally invoke the function using cURL:

```
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d $sqsEvent.json
```


[1]https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
[2] https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
