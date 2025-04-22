# Lambda-Deployment-with-CICD-Pipeline

## Project Overview

This repository demonstrates a straightforward CI/CD setup for deploying an AWS Lambda function using Jenkins, Docker, and Amazon Elastic Container Registry (ECR). The project includes a basic Python Lambda function that prints "Hello, World!" when invoked. The CI/CD pipeline, orchestrated by Jenkins, utilizes Docker for containerized builds and ECR for efficient container image storage.


## Prerequisites

Before you begin, ensure the following prerequisites are met:

- AWS account with appropriate permissions.
- AWS CLI installed.
- Docker installed.
- Jenkins installed.
- Git installed.

## Setup

1. **Lambda Execution Role:**
   - In your AWS account, create a role for the Lambda function with the following permissions:
     - `logs:CreateLogGroup`
     - `logs:CreateLogStream`
     - `logs:PutLogEvents`
   - Alternatively, you can use the default Lambda execution role.

2. **Jenkins AWS Credentials:**
   - Install the AWS credentials extension in Jenkins.
   - Set up AWS credentials in Jenkins with the following details:
     - `credentialsId: 'aws-credentials'`
     - `accessKeyVariable: 'AWS_ACCESS_KEY_ID'`
     - `secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'`

3. **Clone Repository:**
   - Clone the repository using the following commands:
     ```bash
     git clone 
     cd Lambda-Deployment-with-CICD-Pipeline
     ```

4. **Update Jenkinsfile:**
   - Open the `Jenkinsfile` and make the following changes in the `environment` section:
     ```groovy
     environment {
         AWS_REGION = 
         AWS_ACCOUNT_ID = 
         ECR_REPO_NAME =
         IMAGE_NAME = 
         LAMBDA_FUNCTION_NAME =
         IAM_ROLE_ARN = 
     }
     ```
   - Change the values of the environment variables according to your AWS setup.

5. **Run the Pipeline:**
   - Trigger the Jenkins pipeline to build, push, and deploy the Docker image and Lambda function.

You are now ready to deploy the Lambda function using Jenkins and Docker.
