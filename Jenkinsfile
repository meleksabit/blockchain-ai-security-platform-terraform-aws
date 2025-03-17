pipeline {
    agent any
    environment {
        // Set environment variables
        ECR_REGISTRY = credentials('ecr-registry-uri')
        AWS_REGION = 'eu-central-1'
        DOCKER_TAG = 'latest'
    }
    stages {
        stage('Build and Push ai-agent') {
            agent {
                docker {
                    image 'docker:24-dind'
                    args '--privileged'
                    reuseNode true
                }
            }
            when {
                changeset "ai-agent/**"
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") { // AWS creds stored in Jenkins
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}'
                    sh 'docker build -t ${ECR_REGISTRY}/ai-agent:${DOCKER_TAG} ./ai-agent'
                    sh 'docker push ${ECR_REGISTRY}/ai-agent:${DOCKER_TAG}'
                }
            }
        }
        stage('Build and Push Go Microservices') {
            agent {
                docker {
                    image 'docker:24-dind'
                    args '--privileged'
                    reuseNode true
                }
            }
            when {
                anyOf {
                    changeset "go-services/blockchain-monitor/**"
                    changeset "go-services/anomaly-detector/**"
                }
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}'
                    script {
                        def services = ['blockchain-monitor', 'anomaly-detector']
                        services.each { svc ->
                            sh "docker build -t ${ECR_REGISTRY}/${svc}:${DOCKER_TAG} ./go-services/${svc}"
                            sh "docker push ${ECR_REGISTRY}/${svc}:${DOCKER_TAG}"
                        }
                    }
                }
            }
        }
        stage('Build and Push Dashboard') {
            agent {
                docker {
                    image 'docker:24-dind'
                    args '--privileged'
                    reuseNode true
                }
            }
            when {
                changeset "dashboard/**"
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}'
                    sh 'docker build -t ${ECR_REGISTRY}/dashboard:${DOCKER_TAG} ./dashboard'
                    sh 'docker push ${ECR_REGISTRY}/dashboard:${DOCKER_TAG}'
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                    sh 'helm upgrade --install ai-agent ./helm/ai-agent --namespace default --set image.repository=${ECR_REGISTRY}/ai-agent'
                    sh 'helm upgrade --install blockchain-monitor ./helm/go-microservices/blockchain-monitor --namespace default'
                    sh 'helm upgrade --install anomaly-detector ./helm/go-microservices/anomaly-detector --namespace default'
                    sh 'helm upgrade --install dashboard ./helm/dashboard --namespace default'
                }
            }
        }
    }
    post {
        always {
            sh 'echo "Pipeline complete!"'
        }
        failure {
            echo 'Build failed!'
        }
    }
}
