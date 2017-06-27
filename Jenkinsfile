pipeline {
  agent {
    # Requires 'ps' to be able to function correctly
    dockerfile { dir 'build' }
  }
  stages {
    stage('Prepare') {
      steps {
        sh 'id'
        sh 'strace 0install --version'
        sh 'yes | strace -f sh -c "0install -cv add 0compile http://0install.net/2006/interfaces/0compile.xml"'
        sh 'yes | strace 0install -cv add 0publish http://0install.net/2006/interfaces/0publish'
        sh 'yes | strace 0install -cv add 0template http://0install.net/tools/0template.xml'
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
