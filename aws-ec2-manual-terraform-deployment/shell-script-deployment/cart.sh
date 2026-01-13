#!/bin/bash
set -euxo pipefail
# -e  exit on error
# -u  error on undefined vars
# -x  print commands (debug)
# pipefail  fail if any piped command fails

# ------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------
exec > /var/log/cart-userdata.log 2>&1

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
# Configure Java globally
# ------------------------------------------------------------------
cat <<EOF >/etc/profile.d/jdk.sh
export JAVA_HOME=/opt/jdk-21
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

source /etc/profile.d/jdk.sh
java -version

# ------------------------------------------------------------------
# Maven requirements
# ------------------------------------------------------------------
export HOME=/root
mkdir -p /root/.m2

# ------------------------------------------------------------------
# Start UI service
# ------------------------------------------------------------------
cd /opt/retail-store-sample-app/src/cart
chmod +x mvnw

nohup ./mvnw spring-boot:run > /var/log/cart.log 2>&1 &
