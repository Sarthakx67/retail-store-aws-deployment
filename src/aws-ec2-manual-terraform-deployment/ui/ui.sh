#!/bin/bash

set -euxo pipefail

# ------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------
exec > /var/log/ui-userdata.log 2>&1

# ------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------
yum update -y
yum install -y git wget tar

# ------------------------------------------------------------------
# Clone application
# ------------------------------------------------------------------
cd /opt
git clone https://github.com/aws-containers/retail-store-sample-app.git

# ------------------------------------------------------------------
# Install Java 21
# ------------------------------------------------------------------
cd /opt

JDK_TAR="openjdk-21_linux-x64_bin.tar.gz"
JDK_URL="https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/${JDK_TAR}"

wget -q "${JDK_URL}"

rm -rf /opt/jdk-21 /opt/jdk-tmp
mkdir /opt/jdk-tmp

tar -xvf "${JDK_TAR}" -C /opt/jdk-tmp --strip-components=1

mv /opt/jdk-tmp /opt/jdk-21

# ------------------------------------------------------------------
# Configure Java
# ------------------------------------------------------------------
cat <<EOF >/etc/profile.d/jdk.sh
export JAVA_HOME=/opt/jdk-21
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

source /etc/profile.d/jdk.sh
java -version

# ------------------------------------------------------------------
# UI environment variables
# ------------------------------------------------------------------
cat <<EOF >/etc/profile.d/ui-env.sh
export RETAIL_UI_DISABLE_DEMO_WARNINGS=true
export RETAIL_UI_ENDPOINTS_CATALOG=http://catalog.stallions.space:8080
export RETAIL_UI_ENDPOINTS_CARTS=http://cart.stallions.space:8080
export RETAIL_UI_ENDPOINTS_ORDERS=http://orders.stallions.space:8080
export RETAIL_UI_ENDPOINTS_CHECKOUT=http://checkout.stallions.space:8080
EOF

source /etc/profile.d/ui-env.sh

# ------------------------------------------------------------------
# Maven requirements
# ------------------------------------------------------------------
export HOME=/root
mkdir -p /root/.m2

# ------------------------------------------------------------------
# Start UI service
# ------------------------------------------------------------------
cd /opt/retail-store-sample-app/src/ui
chmod +x mvnw

nohup ./mvnw spring-boot:run > /var/log/ui.log 2>&1 &