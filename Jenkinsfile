// -*- mode: groovy-mode; groovy-indent-offset: 4 -*-

@Library('jenkins-pipeline-library') _

pipeline {
  agent {label 'docker'}
  stages {
    stage('Build') {
      steps {
        // Checkout code
        checkout scm
        sh './build.sh'
	archiveArtifacts artifacts: 'openresty-*.tar.gz', followSymlinks: false
      }
    }
  }
}