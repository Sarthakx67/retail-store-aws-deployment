#!/bin/bash

set -euxo pipefail
# -e  exit on error
# -u  error on undefined vars
# -x  print commands (debug)

# ------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------
exec > /var/log/catalog-userdata.log 2>&1

# ------------------------------------------------------------------
# Base packages
# ------------------------------------------------------------------
yum update -y
yum install -y git go

# ------------------------------------------------------------------
# Go runtime setup (required in cloud-init)
# ------------------------------------------------------------------
export HOME=/root
# cloud-init is not a login shell → HOME is not set

export GOPATH=/opt/go
export GOMODCACHE=$GOPATH/pkg/mod
export GOCACHE=/opt/go/cache
# Explicit Go cache paths (Go fails without these)

mkdir -p $GOMODCACHE $GOCACHE
# Create required directories

# ------------------------------------------------------------------
# Clone application 
# ------------------------------------------------------------------
APP_DIR="/opt/retail-store-sample-app"

if [ ! -d "$APP_DIR" ]; then
  cd /opt
  git clone https://github.com/aws-containers/retail-store-sample-app.git
fi

# ------------------------------------------------------------------
# Build catalog service
# ------------------------------------------------------------------
cd "$APP_DIR/src/catalog"

go version   # log Go version
go env       # log Go environment

go build -o catalog main.go

# ------------------------------------------------------------------
# Start catalog service
# ------------------------------------------------------------------
nohup ./catalog > /var/log/catalog.log 2>&1 &
