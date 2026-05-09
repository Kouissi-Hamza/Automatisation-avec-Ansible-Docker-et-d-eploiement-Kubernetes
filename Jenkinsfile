pipeline {
  agent {
    docker {
      image 'maven:3.9.4-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  environment {
    IMAGE = "p4vl1n/automatisation_avec_ansible"
    TAG = "v1"
  }
  stages {
    stage('Checkout') {
      steps { git url: 'https://github.com/Kouissi-Hamza/Automatisation-avec-Ansible-Docker-et-d-eploiement-Kubernetes.git', branch: 'main' }
    }
    stage('Build and Test') {
      steps { sh 'mvn -B -DskipTests=false clean package' }
    }
    stage('Build image') {
      steps {
        sh "docker build -t ${IMAGE}:${TAG} ."
        sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
      }
    }
    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
            sh "docker push ${IMAGE}:${TAG}"
            sh "docker push ${IMAGE}:latest"
          }
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps { sh 'ansible-playbook -i localhost, -c local playbooks/deploy.yml' }
    }
  }
  post { always { sh 'docker logout || true' } }
}
