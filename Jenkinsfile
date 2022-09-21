pipeline {
  parameters {
    string(name: 'DOCKER_IMAGE', defaultValue: 'docker-qa-local.docker.scm.tripwire.com/axon/jenkins2/axon-ruby-cookbooks:latest', description: 'Docker image to use.')
  }
  agent {
    docker {
      label 'docker'
      image params.DOCKER_IMAGE
    }
  }
  options {
    timeout(time: 1, unit: 'HOURS')
  }
  stages {
    stage('Publish to Chef Supermarket'){
      steps {
        // read USER_NAME from Jenkins
        withCredentials([file(credentialsId: 'supermarket_key', variable: 'KEY_FILE')]) {
          sh("chef exec stove --username $USER_NAME --key $KEY_FILE --endpoint https://supermarket.chef.io/api/v1 --no-git --no-ssl-verify")
        }
      }
    }
  }
}
