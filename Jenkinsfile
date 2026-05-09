pipeline {
  agent any

  environment {
    IMAGE = "p4vl1n/automatisation_avec_ansible"
    TAG = "v1"
    DOCKERHUB_CREDENTIALS = "dockerhub-creds"

  }

  options {
    timestamps()
    ansiColor('xterm')
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
          // If you store kubeconfig as a Jenkins secret text credential, write it to a file
          withCredentials([string(credentialsId: "${KUBECONFIG_CREDENTIAL}", variable: 'KUBECONFIG_CONTENT')]) {
            sh '''
              if [ -n "$KUBECONFIG_CONTENT" ]; then
                mkdir -p $WORKSPACE/.kube
                echo "$KUBECONFIG_CONTENT" > $WORKSPACE/.kube/config
                export KUBECONFIG=$WORKSPACE/.kube/config
              fi
              ansible-playbook -i localhost, -c local playbooks/deploy.yml --verbose
            '''
          }
          // If you don't use kubeconfig credential, run directly:
          sh '''
            if [ -z "$KUBECONFIG_CONTENT" ]; then
              ansible-playbook -i localhost, -c local playbooks/deploy.yml --verbose
            fi
          '''
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
