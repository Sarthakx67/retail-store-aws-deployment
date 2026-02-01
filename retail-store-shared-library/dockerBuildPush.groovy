def call(Map config) {

    sh "docker build -t ${env.IMAGE} src/${config.service}"

    withCredentials([usernamePassword(
        credentialsId: 'dockerhub-creds',
        usernameVariable: 'USER',
        passwordVariable: 'PASS'
    )]) {
        sh 'echo $PASS | docker login -u $USER --password-stdin'
    }

    sh "docker push ${env.IMAGE}"
}
