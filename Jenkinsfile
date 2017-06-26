pipeline {
  agent {
    docker 'debian:stable'
  }
  stages {
    stage('Build') {
      steps {
	sh '0install --help'
      }
    }
  }
}
