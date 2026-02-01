def call(Map config) {
    script {
        def version

        if (config.type == 'maven') {
            version = sh(
                script: "cd src/${config.service} && mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tail -n 1",
                returnStdout: true
            ).trim()
        }

        else if (config.type == 'go') {
            version = sh(
                script: """
                cd src/${config.service}
                grep -oP '@version\\s+\\K[0-9.]+' main.go
                """,
                returnStdout: true
            ).trim()
        }

        else if (config.type == 'node') {
            def packageJson = readJSON file: "src/${config.service}/package.json"
            version = packageJson.version
        }

        env.VERSION = version
        env.IMAGE = "sarthak6700/retail-store-${config.service}:${version}"

        echo "Version detected: ${version}"
        echo "Docker image: ${env.IMAGE}"
    }
}
