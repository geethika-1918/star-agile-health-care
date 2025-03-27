pipeline {
    agent any
    
    tools {
        maven 'Apache Maven 3.8.7'
        jdk 'openjdk 17.0.14'
    }
    
    stages {
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
                sh 'cd terraform && terraform init && terraform apply -auto-approve authenticator.tf && terraform apply -auto-approve'
            }
        }
        
        stage('Configure Servers') {
            steps {
                sh 'cd ansible && ansible-playbook configure-servers.yml'
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
