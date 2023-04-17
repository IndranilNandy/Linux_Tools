#!/usr/bin/env bash

# Ref: https://helm.sh/docs/intro/install/#from-script
install_helm() {
    curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 /tmp/get_helm.sh
    /tmp/get_helm.sh
}

bash_auto_complete() {
    helm completion bash | sudo tee /etc/bash_completion.d/helm

}

install_helm || exit 1
bash_auto_complete
