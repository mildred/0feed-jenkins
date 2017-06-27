// vim: tw=0
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
        sh '''
          lftp -c "open $url; cls" | sed -n 's:^\([0-9\.]*\)/$:\1:p' | sort -V | tail -n 1 >version
        '''
        sh 'echo "Latest version is $(cat version)"'
      }
    }
    stage('Build') {
      steps {
        // Download current interface, strip signature and new version
        sh 'curl -s "$INTERFACE_URL" -o jenkins.xml.old'
        sh '''sed -i '/^<!-- Base64 Signature/,/^-->/ d' <jenkins.xml.old >jenkins.xml.new'''
        sh '''sed -i '/<implementation .*version=["'"'"']'"$(cat version)"'["'"'"']/,/<\/implementation>/ d' jenkins.xml.new'''
        sh 'diff -u jenkins.xml.old jenkins.xml.new'

        // Generate new snippet for new version
        sh '0template -o jenkins.xml.snip jenkins.xml.template version=$(cat version)'
        sh 'cat jenkins.xml.snip'
        sh '0publish -a jenkins.xml.snip jenkins.xml.new'
        sh 'diff -u jenkins.xml.old jenkins.xml.new'

        // Sign new interface
        writeFile file: "passphrase",
          text: credentials('gpgkeys/0install/D560546EA16D1D39/passphrase')
        sh '''
          eval "$(gpg-agent --batch --enable-ssh-support -s)"
          gpg --passphrase-file passphrase --batch --import "$GPG_KEY_ID.skey"
          gpg --passphrase-file passphrase --batch --default-key $GPG_KEY_ID \
            --sign --detach-sign --output jenkins.xml.sig jenkins.xml.new
          printf "<!-- Base64 Signature\n%s\n-->\n" \
            $(base64 -w0 <jenkins.xml.sig) >>jenkins.xml.new
          gpg --passphrase-file passphrase --batch \
            --armor --output $GPG_KEY_ID.gpg --export $GPG_KEY_ID || true
          rm passphrase
        '''
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
