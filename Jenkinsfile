pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '792527467644'
        ECR_REPO_NAME = 'etranz-lambda'
        IMAGE_NAME = 'etranz-lambda'
        LAMBDA_FUNCTION_NAME = 'ecr-trigger'
        // IAM_ROLE_ARN = 'arn:aws:iam::054774128594:role/go-digi-task'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate & Create ECR Repo') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    # Authenticate Docker to ECR
                    aws ecr get-login-password --region $AWS_REGION | \
                      docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    # Create ECR repo if it doesn't exist
                    aws ecr describe-repositories --repository-names $ECR_REPO_NAME \
                      || aws ecr create-repository --repository-name $ECR_REPO_NAME
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME .
                docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                '''
            }
        }

        stage('Deploy Lambda Function') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    # Check if Lambda exists, then update or create
                    if aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME > /dev/null 2>&1; then
                      echo "Function exists, updating..."
                      aws lambda update-function-code \
                        --function-name $LAMBDA_FUNCTION_NAME \
                        --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest \
                        --region $AWS_REGION
                    else
                      echo "Creating new Lambda function..."
                      aws lambda create-function \
                        --function-name $LAMBDA_FUNCTION_NAME \
                        --package-type Image \
                        --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest \
                        --role $IAM_ROLE_ARN \
                        --region $AWS_REGION
                    fi
                    '''
                }
            }
        }
    }
}
