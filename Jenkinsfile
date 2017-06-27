// vim: tw=0:ft=groovy
pipeline {
  agent {
    // Requires 'ps' to be able to function correctly (package procps)
    dockerfile { dir 'build' }
  }
  environment {
    GPG_KEY_ID = 'D560546EA16D1D39'
    INTERFACE_URL = 'http://mildred.github.io/0feed-jenkins/jenkins.xml'
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
    stage('Download') {
      environment {
        url = 'http://mirrors.jenkins.io/war/'
      }
      steps {
        sh 'scripts/last-version >version'
        sh 'echo "Latest version is $(cat version)"'
      }
    }
    stage('Build') {
      steps {
        // Download current interface, strip signature and new version
        sh 'curl -s "\$INTERFACE_URL" -o jenkins.xml.old'
        sh 'cp jenkins.xml.old jenkins.xml.new'
        sh 'scripts/strip-signature jenkins.xml.new'
        sh 'scripts/strip-implementation "\$(cat version)" jenkins.xml.new'
        sh 'diff -u jenkins.xml.old jenkins.xml.new'

        // Generate new snippet for new version
        sh '0template -o jenkins.xml.snip jenkins.xml.template version=\$(cat version)'
        sh 'cat jenkins.xml.snip'
        sh '0publish -a jenkins.xml.snip jenkins.xml.new'
        sh 'diff -u jenkins.xml.old jenkins.xml.new'

        // Sign new interface
        writeFile file: "passphrase",
          text: credentials('gpgkeys/0install/D560546EA16D1D39/passphrase')
        sh 'scripts/sign-interface jenkins.xml.new'
        sh 'diff -u jenkins.xml.old jenkins.xml.new'
      }
    }
    stage('Deploy'){
      steps {
        sh '''
          eval "$(gpg-agent --batch --enable-ssh-support -s)"
        '''
      }
    }
  }
}
