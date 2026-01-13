#!/bin/bash
set -e

exec > /var/log/checkout-userdata.log 2>&1

# ------------------------------------------------------------
# PATH (cloud-init safe)
# ------------------------------------------------------------
export PATH=/usr/bin:/usr/local/bin:/bin

# ------------------------------------------------------------
# SYSTEM TOOLS 
# ------------------------------------------------------------
yum update -y
yum install -y \
  git \
  wget \
  golang \
  gcc \
  gcc-c++ \
  make

# ------------------------------------------------------------
# NODE 20
# ------------------------------------------------------------
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# ------------------------------------------------------------
# YARN
# ------------------------------------------------------------
npm install -g yarn

# ------------------------------------------------------------
# CLONE REPO
# ------------------------------------------------------------
cd /opt
rm -rf retail-store-sample-app || true
git clone https://github.com/aws-containers/retail-store-sample-app.git

# ------------------------------------------------------------
# INSTALL ALL DEPS (YES, ALL)
# ------------------------------------------------------------
cd /opt/retail-store-sample-app
yarn install --ignore-engines || true

# ------------------------------------------------------------
# BUILD CHECKOUT (NX)
# ------------------------------------------------------------
yarn nx run checkout:build || true

# ------------------------------------------------------------
# FIND BUILD OUTPUT (BRUTE FORCE)
# ------------------------------------------------------------
echo "Finding checkout build output..."
CHECKOUT_DIR=$(find dist -type f -name main.js | head -n 1 | xargs dirname)

echo "Checkout build dir = $CHECKOUT_DIR"

# ------------------------------------------------------------
# RUN SERVICE (UGLY BUT RUNS)
# ------------------------------------------------------------
pkill node || true
cd "$CHECKOUT_DIR"

nohup node main.js > /var/log/checkout.log 2>&1 &
