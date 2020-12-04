variable "default_tags" {
  type = map(any)
  default = {
    "environment" = "test"
  }
}

variable "imagename" {
  type = string
}

variable "queue_name" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "region" {
  type = string
}