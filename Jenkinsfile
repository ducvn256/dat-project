pipeline {
  agent {
    label "jenkins-jx-base"
  }
  environment {
    ORG = 'ducvn256'
    APP_NAME = 'dat-project'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    DOCKER_REGISTRY_ORG = 'ducvn256'
  }
  stages {
    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('dotnet22') {
          // sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          // sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          // dir('./charts/preview') {
          //   sh "make preview"
          //   sh "jx preview --app $APP_NAME --dir ../.."
          // }
		  
		  
		  sh 'dotnet restore "WebApplication/WebApplicationApi/WebApplication.csproj" --configfile Api/Nuget.config -nowarn:msb3202,nu1503 --verbosity diag'
          dir('./WebApplication/WebApplicationApi') {
            sh 'dotnet build "WebApplication.csproj" -c Release -o ./app'
          }
          dir('./WebApplication/WebApplicationApi') {
            sh 'dotnet publish "WebApplication.csproj" -c Release -o ./app'
          }
          sh "skaffold version"
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('./charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."                 
          }
        }
      }
    }
    stage('Build Release') {
      when {
        branch 'master'
      }
      steps {
        container('jx-base') {

          // ensure we're not on a detached head
          sh "git checkout master"
          sh "git config --global credential.helper store"
          sh "jx step git credentials"
          sh "jx step next-version --use-git-tag-only --tag"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }
    stage('Promote to Environments') {
      when {
        branch 'master'
      }
      steps {
        container('jx-base') {
          dir('./charts/dat-project') {
            sh "jx step changelog --version v\$(cat ../../VERSION)"

            // release the helm chart
            sh "jx step helm release"

            // promote through all 'Auto' promotion Environments
            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
          }
        }
      }
    }
  }
  post {
        always {
          cleanWs()
        }
  }
}
