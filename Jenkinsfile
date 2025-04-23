pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '792527467644'
        ECR_REPO_NAME = 'etranz-lambda'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
        IMAGE_NAME = 'etranz-lambda'
        LAMBDA_FUNCTION_NAME = 'ecr-trigger'
        // IAM_ROLE_ARN = 'arn:aws:iam::your-account-id:role/your-lambda-role'  // <- Uncomment and set this!
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
                    echo "Authenticating Docker with ECR..."
                    aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "Ensuring ECR repository exists..."
                    aws ecr describe-repositories --repository-names $ECR_REPO_NAME || \
                        aws ecr create-repository --repository-name $ECR_REPO_NAME
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                sh '''
                echo "Building Docker image..."
                docker build -t $IMAGE_NAME .

                echo "Tagging Docker image..."
                docker tag $IMAGE_NAME:latest $ECR_URI:latest

                echo "Pushing Docker image to ECR..."
                docker push $ECR_URI:latest
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
                    echo "Deploying Lambda function..."
                    if aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME > /dev/null 2>&1; then
                        echo "Function exists. Updating..."
                        aws lambda update-function-code \
                            --function-name $LAMBDA_FUNCTION_NAME \
                            --image-uri $ECR_URI:latest \
                            --region $AWS_REGION
                    else
                        echo "Creating new Lambda function..."
                        aws lambda create-function \
                            --function-name $LAMBDA_FUNCTION_NAME \
                            --package-type Image \
                            --code ImageUri=$ECR_URI:latest \
                            --role $IAM_ROLE_ARN \
                            --region $AWS_REGION
                    fi
                    '''
                }
            }
        }
    }
}
