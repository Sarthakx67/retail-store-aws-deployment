def call(Map config) {

    pipeline {
        agent { label config.agent ?: 'AGENT-1' }

        stages {
            stage('Detect Version') {
                steps {
                    detectVersion(service: config.service, type: config.type)
                }
            }

            stage('Build & Push Image') {
                steps {
                    dockerBuildPush(service: config.service)
                }
            }
            stage('Checkout Helm Repo') {
                steps {
                    dir('helm-repo') {
                        git url: 'https://github.com/Sarthakx67/retail-store-aws-deployment.git', branch: 'main'
                    }
                }
            }
            stage('Deploy') {
                steps {
                    deployK8s(
                        service: config.service,
                        version: env.VERSION,
                        namespace: config.namespace,
                        env: config.env
                    )
                }
            }
        }
    }
}
