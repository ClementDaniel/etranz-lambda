pipeline {
    agent { label 'docker-enabled' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '792527467644'
        ECR_REPO_NAME = 'etranz-lambda'
        IMAGE_NAME = 'etranz-lambda'
        LAMBDA_FUNCTION_NAME = 'ecr-trigger'
        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push to ECR and Deploy to Lambda') {
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ],
                    string(credentialsId: 'lambda-role-arn', variable: 'IAM_ROLE_ARN')
                ]) {
                    sh '''
                        # Login to ECR
                        aws ecr get-login-password --region $AWS_REGION | \
                          docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                        # Create ECR repository if it doesn't exist
                        aws ecr describe-repositories --repository-names $ECR_REPO_NAME > /dev/null 2>&1 \
                          || aws ecr create-repository --repository-name $ECR_REPO_NAME

                        # Tag and push the image to ECR
                        docker tag $IMAGE_NAME:latest $IMAGE_URI
                        docker push $IMAGE_URI

                        # Deploy to Lambda
                        if aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME > /dev/null 2>&1; then
                            echo "Updating existing Lambda function..."
                            aws lambda update-function-code \
                                --function-name $LAMBDA_FUNCTION_NAME \
                                --image-uri $IMAGE_URI \
                                --region $AWS_REGION
                        else
                            echo "Creating new Lambda function..."
                            aws lambda create-function \
                                --function-name $LAMBDA_FUNCTION_NAME \
                                --package-type Image \
                                --code ImageUri=$IMAGE_URI \
                                --role $IAM_ROLE_ARN \
                                --region $AWS_REGION
                        fi
                    '''
                }
            }
        }
    }
}
