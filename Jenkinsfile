pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_URI = '792527467644.dkr.ecr.us-east-1.amazonaws.com/etranz-lambda'
        IMAGE_NAME = 'etranz-lambda'
        LAMBDA_FUNCTION_NAME = 'ecr-trigger'
        // IAM_ROLE_ARN = 'arn:aws:iam::054774128594:role/go-digi-task'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                     git 'https://github.com/ClementDaniel/etranz-lambda.git'
                }
            }
        }

        stage('Create a ECR repository & Authentication of Docker client') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 792527467644.dkr.ecr.us-east-1.amazonaws.com
                    aws ecr create-repository --repository-name $ECR_REPO_NAME
                    '''
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh '''
                    docker build -t $IMAGE_NAME .
                    docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
                    '''
                }
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
                    aws lambda create-function --function-name $LAMBDA_FUNCTION_NAME --package-type Image --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest --role $IAM_ROLE_ARN --region $AWS_REGION
                    '''
                }
            }
        }
    }
}
