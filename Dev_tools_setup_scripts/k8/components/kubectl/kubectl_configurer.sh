#!/usr/bin/env bash

envloader="$MYCONFIGLOADER"/.envloader
kubecomplete='source <(kubectl completion bash)'
# Enable kubectl autocompletion
enable_autocompletion() {
    echo "$kubecomplete" >>"$envloader"
}

# Install kubectl convert plugin
install_convert() {
    mkdir tmp
    (
        cd tmp
        # Download latest release
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
        # Validate the binary
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"
        echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check | return 1
        # Install kubectl-convert
        sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert
        # Verify plugin installation
        kubectl convert --help
    )
    rm -rf tmp
    return 0
}

# Enable kubectl autocompletion
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-shell-autocompletion
grep -q "$kubecomplete" "$envloader" || enable_autocompletion

# Install kubectl convert plugin
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-convert-plugin

! (kubectl convert --help) && ! install_convert && echo -e "[KUBECTL] Warning! Kubectl convert plugin installation failed"
exit 0
