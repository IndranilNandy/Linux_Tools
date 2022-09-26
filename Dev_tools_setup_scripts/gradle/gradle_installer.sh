#!/usr/bin/env bash

instl_script=' source ~/.bashrc; \
latest_version=$(sdk list gradle | head -n4 | tail -n1 | awk "{ print \$1 }"); \
echo "Installing latest version: $latest_version"; \
sdk install gradle $latest_version; \
exit 0 '

bash --init-file <(echo "$instl_script;")

