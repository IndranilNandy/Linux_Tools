#!/usr/bin/env bash

. .config

create_refstore() {
    [[ -d "$refloader" ]] && echo -e "[refloader] Already exists" && return 0
    mkdir -p "$refloader" && echo -e "[refloader] .refloader created"
}

create_refstore