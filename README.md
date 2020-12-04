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
