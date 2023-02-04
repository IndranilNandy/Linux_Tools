#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params

init_config() {
    local run_id="${1}"
    local dfile="${2}"
    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$run_config_dir"

    mkdir -p "$dfile_cfgdir"
    mkdir -p "$build_config_path"
    mkdir -p "$run_config_path"

    [[ -e "$build_config_path"/"0.buildconfig" ]] || cp "$default_cfg_template"/"$default_build_cfg" "$build_config_path"/"0.buildconfig"
    [[ -e "$run_config_path"/"0.runconfig" ]] || cp "$default_cfg_template"/"$default_run_cfg" "$run_config_path"/"0.runconfig"

    echo "$dfile" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runfile"
}

build_config_template() {
    local dfile="${1}"
    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$build_config_dir"

    echo "$build_config_path"/"0.buildconfig"
}

run_config_template() {
    local dfile="${1}"
    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$run_config_dir"

    echo "$run_config_path"/"0.runconfig"
}

replace() {
    key="${1}"
    val="${2}"
    sed "s#\(.*\)$key\(.*\)#\1$val\2#"
}

run_file() {
    local run_id="${1}"
    cat /tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runfile"
}

cfg_builder() {
    local cfg="${1}"
    local -n cfgmap_ref=${2}

    cat "$cfg" |
        replace "$image_pholder" ${cfgmap_ref[$image_pholder]} |
        replace "$imagev_pholder" ${cfgmap_ref[$imagev_pholder]} |
        replace "$dfile_pholder" ${cfgmap_ref[$dfile_pholder]} |
        replace "$context_pholder" ${cfgmap_ref[$context_pholder]} |
        replace "$container_pholder" ${cfgmap_ref[$container_pholder]}
}

buildcfg_builder() {
    local run_id="${1}"
    local -n build_cfgmap_ref=${2}
    local dfile=$(run_file "$run_id")

    cfg_builder "$(build_config_template $dfile)" build_cfgmap_ref
}

runcfg_builder() {
    local run_id="${1}"
    local -n run_cfgmap_ref=${2}
    local dfile=$(run_file "$run_id")

    cfg_builder "$(run_config_template $dfile)" run_cfgmap_ref
}
