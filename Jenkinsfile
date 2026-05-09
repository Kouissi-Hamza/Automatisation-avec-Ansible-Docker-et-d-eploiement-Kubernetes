pipeline {
  agent any

  environment {
    IMAGE = "p4vl1n/automatisation_avec_ansible"
    TAG = "v1"
    DOCKERHUB_CREDENTIALS = "dockerhub-creds"
    KUBECONFIG_FILE_ID = "kubeconfig-file" // Secret file credential ID
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build and Test') {
      steps {
        sh 'mvn -B -DskipTests=false clean package'
      }
      post {
        always {
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
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
          docker.withRegistry('https://registry.hub.docker.com', "${DOCKERHUB_CREDENTIALS}") {
            sh "docker push ${IMAGE}:${TAG}"
            sh "docker push ${IMAGE}:latest"
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          withCredentials([file(credentialsId: "${KUBECONFIG_FILE_ID}", variable: 'KUBECONFIG_FILE')]) {
            sh '''
              export KUBECONFIG="$KUBECONFIG_FILE"
              echo "Using kubeconfig at $KUBECONFIG"
              ansible-playbook -i localhost, -c local playbooks/deploy.yml --verbose
            '''
          }
        }
      }
    }

    stage('Cleanup') {
      steps {
        sh 'docker logout || true'
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded"
    }
    failure {
      echo "Pipeline failed"
    }
    always {
      echo "Pipeline finished"
    }
  }
}
