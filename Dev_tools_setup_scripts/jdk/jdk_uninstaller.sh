#!/usr/bin/env bash

# uninstl_script=' source ~/.bashrc; \
# sdk uninstall gradle $(sdk current gradle | awk "{print \$4}"); \
# exit 0 '

# bash --init-file <(echo "$uninstl_script;")

for ver in $(cat $(pwd)/.jdkversions | grep -E -v " *#"); do
    uninstl_script=" source ~/.bashrc; \
echo \"Uninstalling version: $ver\"; \
sdk uninstall java $ver; \
exit 0 "
    echo -e "$uninstl_script"
    bash --init-file <(echo "$uninstl_script;")
done
