pipeline {
  agent {
    docker 'debian:stable'
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'wget https://downloads.sourceforge.net/project/zero-install/0install/2.12.1/0install-linux-x86_64-2.12.1.tar.bz2'
        sh 'tar xf 0install-linux-x86_64-2.12.1.tar.bz2'
        sh '( cd 0install-linux-x86_64-2.12.1 && ./install.sh home )'
      }
    }
    stage('Build') {
      steps {
        sh '0install --help'
      }
    }
  }
}
