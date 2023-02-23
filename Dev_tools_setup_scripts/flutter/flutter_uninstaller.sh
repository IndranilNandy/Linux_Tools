#!/usr/bin/env bash

remove_flutter() {
    sudo snap remove --purge flutter
}

remove_flutter
./dart/dart_env_remover.sh