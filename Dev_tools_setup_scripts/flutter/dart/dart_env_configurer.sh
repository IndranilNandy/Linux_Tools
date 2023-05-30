#!/usr/bin/env bash

dart_global_pkgs() {
    all_pkgs=("webdev")
    echo -e "Activating Global Packages ->"
    echo -e "${all_pkgs[@]}";
    echo -e
    for pkg in "${all_pkgs[@]}"; do
        (dart pub global list | grep -q "$pkg") && echo "$pkg is already activated" || (echo "activating $pkg" && dart pub global activate "$pkg")
    done
}

configure_env_vars() {
    myshpath add --path="$HOME/.pub-cache/bin"
}

dart_global_pkgs
configure_env_vars