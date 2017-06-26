pipeline {
  agent {
    dockerfile { dir 'build' }
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'id'
        sh '0install --version'
      }
    }
    stage('Build') {
      steps {
        sh '0install --help'
      }
    }
  }
}
