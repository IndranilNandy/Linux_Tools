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
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$build_config_dir"

    cur_build_cfg_file="/tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curBuildCfg"

    if [[ -e "$cur_build_cfg_file" ]]; then
        cat "$cur_build_cfg_file"
    else
        echo "$build_config_path"/"0.buildconfig"
    fi
}

run_config_template() {
    local dfile="${1}"
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$run_config_dir"

    cur_run_cfg_file="/tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curRunCfg"

    if [[ -e "$cur_run_cfg_file" ]]; then
        cat "$cur_run_cfg_file"
    else
        echo "$run_config_path"/"0.runconfig"
    fi
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
    cfg_builder "$(build_config_template $dfile $run_id)" build_cfgmap_ref
}

runcfg_builder() {
    local run_id="${1}"
    local -n run_cfgmap_ref=${2}
    local dfile=$(run_file "$run_id")
    cfg_builder "$(run_config_template $dfile $run_id)" run_cfgmap_ref
}

updateBuildConfigFiles() {
    local dfile="${1}"
    local build_config_path="${2}"
    local run_id="${3}"

    local build_cfg_file=
    local tempfile=/tmp/buildConfigPath-"$(date +%N)"

    find "$build_config_path" -name "*.buildconfig" -type f >"$tempfile"

    count_of_buildConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_buildConfigs == 0)) && echo -e "No .buildconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_buildConfigs == 1)); then
        build_cfg_file="$(cat "$tempfile")"
        echo "$build_cfg_file"
    else
        echo -e "Multiple .buildconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .buildconfig to choose? Enter the number: " no
        build_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        echo "$build_cfg_file"
    fi

    editor -w "$build_cfg_file"
    echo "$build_cfg_file" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curBuildCfg"

    rm "$tempfile"
    return 0
}

updateRunConfigFiles() {
    local dfile="${1}"
    local run_config_path="${2}"
    local run_cfg_file=
    local tempfile=/tmp/runConfigPath-"$(date +%N)"

    # echo "hash = $hash"
    # echo "bfcg_path = $run_config_path"

    find "$run_config_path" -name "*.runconfig" -type f >"$tempfile"

    count_of_runConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_runConfigs == 0)) && echo -e "No .runconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_runConfigs == 1)); then
        run_cfg_file="$(cat "$tempfile")"
        echo "$run_cfg_file"
    else
        echo -e "Multiple .runconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .runconfig to choose? Enter the number: " no
        run_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        echo "$run_cfg_file"
    fi

    editor -w "$run_cfg_file"
    echo "$run_cfg_file" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curRunCfg"

    rm "$tempfile"
    return 0
}

updateConfigFiles() {
    local dfile="${1}"
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$run_config_dir"

    updateBuildConfigFiles "$dfile" "$build_config_path" "$run_id"
    updateRunConfigFiles "$dfile" "$run_config_path" "$run_id"
}

# f=/home/indranilnandy/DEV/GIT-REPOS/PracticeWS/IDEwise/Vscode/Java/javatest2/buildInDocker
# # updateBuildConfigFiles "$f"
# # updateRunConfigFiles "$f"
# updateConfigFiles "$f"
