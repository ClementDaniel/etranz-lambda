pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_URI = '792527467644.dkr.ecr.us-east-1.amazonaws.com/etranz-lambda' 
        IMAGE_NAME = 'etranz-lambda'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                pack build $IMAGE_NAME \
                  --builder paketobuildpacks/quarkus:latest \
                  --path . \
                  --tag $IMAGE_NAME:latest
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
                docker tag $IMAGE_NAME:latest $ECR_URI/$IMAGE_NAME:latest
                docker push $ECR_URI/$IMAGE_NAME:latest
                """
            }
        }

        stage('Deploy to Lambda') {
            steps {
                sh """
                aws lambda update-function-code \
                  --function-name etranz-lambda-fn \
                  --image-uri $ECR_URI/$IMAGE_NAME:latest \
                  --region $AWS_REGION
                """
            }
        }
    }
}
