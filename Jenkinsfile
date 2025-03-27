pipeline {
    agent any
    
    tools {
        maven 'Maven'
        jdk 'JDK'
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
        
        stage('Docker Build') {
            steps {
                sh 'docker build -t medicure:${BUILD_NUMBER} .'
            }
        }
        
        stage('Provision Test Infrastructure') {
            steps {
                sh 'cd terraform && terraform init && terraform apply -auto-approve'
            }
        }
        
        stage('Configure Servers') {
            steps {
                sh 'cd ansible && ansible-playbook configure-servers.yml'
            }
        }
        
        stage('Deploy to Test') {
            steps {
                sh 'kubectl apply -f kubernetes/test-deployment.yml'
            }
        }
        
        stage('Run Selenium Tests') {
            steps {
                sh 'cd selenium && mvn test'
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
