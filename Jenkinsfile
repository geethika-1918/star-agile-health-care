pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1" // Change to your AWS region
    }

    tools {
        maven 'Apache Maven 3.8.7'
        jdk 'openjdk 17.0.14'
    }

    stages {
        stage('Setup AWS Credentials') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                    '''
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Provision Test Infrastructure') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                '''
            }
        }

        stage('Configure Servers') {
            steps {
                sh '''
                    cd ansible
                    ansible-playbook configure-servers.yml
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t medicure:${BUILD_NUMBER} .'
            }
        }

        stage('Deploy to Test') {
            steps {
                sh 'kubectl apply -f kubernetes/test-deployment.yml'
            }
        }

        stage('Deploy to Production') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }
            steps {
                sh 'kubectl apply -f kubernetes/prod-deployment.yml'
            }
        }

        stage('Setup Monitoring') {
            steps {
                sh 'kubectl apply -f kubernetes/prometheus-grafana.yml'
            }
        }
    }
}
