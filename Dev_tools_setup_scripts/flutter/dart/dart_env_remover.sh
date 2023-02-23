#!/usr/bin/env bash

remove_dart_env() {
    myshpath remove --path="$HOME/.pub-cache/bin"
}

remove_pub_cache() {
    rm -rf "$HOME/.pub-cache"
}

remove_dart_env
remove_pub_cache