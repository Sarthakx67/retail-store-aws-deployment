def call(Map config) {

    sh """
    echo "🚀 Deploying ${config.service} version ${config.version}"

    git clone https://github.com/Sarthakx67/retail-store-aws-deployment.git
    cd retail-store-aws-deployment

    sed -i "s/tag: v1/tag: ${config.version}/" \
    retail-store-helm-chart/values/${config.env}/values-${config.env}.yaml

    git config user.email "jenkins@ci.com"
    git config user.name "Jenkins"
    git add .
    git commit -m "ci: update ${config.service} to ${config.version}"
    git push
    
    """
}
    // update the exact key in the exact file
    // ```
    // ArgoCD detects the Git change within 3 minutes, syncs automatically, deploys v2. No drift, no fighting.
    // ---
    // **The pattern has a name — Image Updater or GitOps Push:**
    // ```
    // Jenkins:  build image → push DockerHub → update Git → push
    // ArgoCD:   detects Git change → syncs cluster