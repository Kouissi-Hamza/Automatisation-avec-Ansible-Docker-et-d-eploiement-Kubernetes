pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = "p4vl1n"
        IMAGE_NAME = "automatisation_avec_ansible"
        IMAGE_TAG = "v1"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds" // Match your Jenkins Credential ID
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        def customImage = docker.build("${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}")
                        customImage.push()
                        customImage.push("latest")
                    }
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sh 'ansible-playbook playbooks/deploy.yml'
            }
        }
    }
}
