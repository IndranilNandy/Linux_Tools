#!/usr/bin/env bash

uninstall_dbeaver() {
    yes | sudo snap remove dbeaver-ce
}

uninstall_dbeaver