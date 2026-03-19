#!/bin/bash
set -e

echo "1. Checking AWS credentials in WSL..."
aws sts get-caller-identity || { echo "AWS CLI not configured properly in WSL"; exit 1; }

echo "2. Checking for eksctl and kubectl..."
mkdir -p ./bin/linux
cd ./bin/linux

if ! command -v kubectl &> /dev/null; then
    echo "Downloading kubectl for Linux..."
    curl -sLO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH="$PWD:$PATH"
else
    echo "kubectl is already installed globally (`command -v kubectl`)."
fi

if ! command -v eksctl &> /dev/null; then
    echo "Downloading eksctl for Linux..."
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
    tar -xzf eksctl_Linux_amd64.tar.gz
    chmod +x eksctl
    rm eksctl_Linux_amd64.tar.gz
    export PATH="$PWD:$PATH"
else
    echo "eksctl is already installed globally (`command -v eksctl`)."
fi

echo "3. Verifying versions..."
./kubectl version --client || kubectl version --client
./eksctl version || eksctl version

echo "Setup complete! We are ready to spin up the cluster."
