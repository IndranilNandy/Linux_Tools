#!/usr/bin/env bash

# instl_script=' source ~/.bashrc; \
# # latest_version=$(sdk list gradle | head -n4 | tail -n1 | awk "{ print \$1 }"); \
# latest_version="19-tem"; \
# echo "Installing latest version: $latest_version"; \
# sdk install java $latest_version; \
# exit 0 '

# bash --init-file <(echo "$instl_script;")

for ver in $(cat $(pwd)/.jdkversions | grep -E -v " *#"); do
    instl_script=" source ~/.bashrc; \
echo \"Installing version: $ver\"; \
yes no | sdk install java $ver; \
exit 0 "
    echo -e "$instl_script"
    bash --init-file <(echo "$instl_script;")
done

default_version="17.0.4.1-tem"
set_default=" source ~/.bashrc; \
echo \"Setting default java version: $default_version\"; \
sdk default java $default_version; \
exit 0 "

bash --init-file <(echo "$set_default;")
