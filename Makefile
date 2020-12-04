ACCOUNT_ID=1234567890
FUNCTION_NAME=handle_step_function
IMAGE_NAME=randomname
QUEUE_NAME=step-function-queue
EXECUTION_ROLE=arn:aws:iam::${ACCOUNT_ID}:role/${FUNCTION_NAME}
IMAGE_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:latest
ECR_REGISTRY=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
FUNCTION_ECR_REPOSITORY=${ECR_REGISTRY}/${IMAGE_NAME}:latest
SQS_ARN=arn:aws:sqs:${AWS_REGION}:${ACCOUNT_ID}:${QUEUE_NAME}

all:
	@echo 'Available make targets:'
	@grep '^[^#[:space:]].*:' Makefile

clean:
	rm -rf build

build: build-extension build-function ;

build-function:
	mkdir -p build
	go fmt
	GOOS=linux go build -o build/main main.go
	docker build -t ${IMAGE_NAME} .

push-function-image: check-region-profile-set build-function
	aws ecr get-login-password --region ${AWS_REGION}| docker login --username AWS --password-stdin $(ECR_REGISTRY)
	docker tag $(IMAGE_NAME):latest $(FUNCTION_ECR_REPOSITORY)
	docker push $(FUNCTION_ECR_REPOSITORY)

fmt-tf:
	cd terraform && terraform fmt

init-tf: fmt-tf
	cd terraform && terraform init

plan-tf: init-tf
	terraform plan -var="imagename=${IMAGE_NAME}" \
        -var="lambda_function_name=${FUNCTION_NAME}"  \
		-var="queue_name=${QUEUE_NAME}" \
		-var="region=${AWS_REGION}"

deploy-tf: init-tf
	terraform deploy -var="imagename=${IMAGE_NAME}" \
        -var="lambda_function_name=${FUNCTION_NAME}"  \
		-var="queue_name=${QUEUE_NAME}" \
		-var="region=${AWS_REGION}"

destroy-tf: init-tf
	terraform destroy -var="imagename=${IMAGE_NAME}" \
        -var="lambda_function_name=${FUNCTION_NAME}"  \
		-var="queue_name=${QUEUE_NAME}" \
		-var="region=${AWS_REGION}"

create-function: check-region-profile-set check-role-arn-set deploy-tf push-function-image
	aws lambda create-function \
		--function-name "${FUNCTION_NAME}" \
		--role "${EXECUTION_ROLE}" \
		--region "${AWS_REGION}" \
		--package-type "Image"  \
		--code "ImageUri=${IMAGE_URI}"
	/usr/local/bin/aws lambda create-event-source-mapping \
		--function-name "${FUNCTION_NAME}"  \
		--batch-size 5 \
		--event-source-arn ${SQS_ARN}

update-function:  check-region-profile-set check-role-arn-set build-function
	aws lambda update-function-code \
		--function-name "${FUNCTION_NAME}" \
		--image-uri "${IMAGE_URI}" \
		--region ${AWS_REGION}
	# uploading a new image takes some time for the lambda to digest that. so sleep and
	# then try to publish the version
	sleep 60
	aws lambda publish-version \
		--function-name "${FUNCTION_NAME}" \
		--description "extension test" \
		--region ${AWS_REGION}

delete-function: check-region-profile-set
	aws lambda delete-function \
		--region "${AWS_REGION}" \
		--function-name "${FUNCTION_NAME}"

check-region-profile-set:
	if [ -z "${AWS_REGION}" ]; then \
        echo "AWS_REGION environment variable is not set."; exit 1; \
    fi
	if [ -z "${AWS_PROFILE}" ]; then \
        echo "AWS_PROFILE environment variable is not set."; exit 1; \
    fi

check-role-arn-set:
	if [ -z "${EXECUTION_ROLE}" ]; then \
        echo "function execution role not set."; exit 1; \
    fi

test: build
	go test ./...
