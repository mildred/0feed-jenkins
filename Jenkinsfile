pipeline {
  agent {
    dockerfile { dir 'build' }
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'id'
        sh '0install --version'
        sh 'yes | 0install -c add 0compile http://0install.net/2006/interfaces/0compile.xml'
        sh 'yes | 0install -c add 0publish http://0install.net/2006/interfaces/0publish'
        sh 'yes | 0install -c add 0template http://0install.net/tools/0template.xml'
      }
    }
    stage('Build') {
      steps {
        sh '0install --help'
        sh 'env | sort'
        sh 'eval "$(ssh-agent -s)"'
        sh 'gpg --version'
        sh 'env | sort'
      }
    }
  }
}
