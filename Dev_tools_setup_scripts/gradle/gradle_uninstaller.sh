#!/usr/bin/env bash

uninstl_script=' source ~/.bashrc; \
sdk uninstall gradle $(sdk current gradle | awk "{print \$4}"); \
exit 0 '

bash --init-file <(echo "$uninstl_script;")