#!/usr/bin/env bash

update_packages() {
    sdkmanager --update
}

accept_licenses() {
    yes | sdkmanager --licenses
}

update_packages && accept_licenses