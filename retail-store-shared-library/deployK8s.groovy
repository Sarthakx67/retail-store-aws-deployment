def call(Map config) {
    sh """
    kubectl set image deployment/${config.deployName} ${config.deployName}=$IMAGE

    kubectl rollout status deployment/${config.deployName}

    """
    // sleep 10
    // curl -f ${config.healthUrl} || kubectl rollout undo deployment/${config.deployName}
    // """
}
