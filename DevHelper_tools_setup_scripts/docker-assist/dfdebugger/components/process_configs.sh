#!/usr/bin/env bash

if [ -L "$(which dfdebugger)" ]; then
    curDir="$(dirname "$(tracelink dfdebugger)")"
else
    curDir="$(pwd)"
fi

. "$curDir"/configs/.config-params

processConfigFiles() {
    local dfile="${1}"
    local run_id="${2}"
    local configoption="${3}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"
    local cur_template_dir="$dfile_cfgdir"/"$hash"/"$cur_template"

    case "$configoption" in
    edit-default)
        echo -e "[Config option] edit-default"
        editor -w "$build_config_path"/"$default_build_cfg" && editor -w "$run_config_path"/"$default_run_cfg"

        cp "$build_config_path"/"$default_build_cfg" "$cur_template_dir"/"$cur_build_cfg"
        cp "$run_config_path"/"$default_run_cfg" "$cur_template_dir"/"$cur_run_cfg"
        ;;
    create-config)
        echo -e "[Config option] create-config"
        createConfigFiles "$basedir"/"$dockerfile" "$run_id"
        ;;
    set-current-for-run)
        echo -e "[Config option] set-current-for-run"
        updateConfigFiles "$basedir"/"$dockerfile" "$run_id"
        ;;
    set-current-for-dockerfile)
        echo -e "[Config option] set-current-for-dockerfile"
        updateCurrentConfigFiles "$basedir"/"$dockerfile" "$run_id"
        ;;
    *)
        echo -e "No change in config files"
        echo -e
        ;;
    esac
}

init_config() {
    local run_id="${1}"
    local dfile="${2}"
    local configoption="${3}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"
    local cur_template_dir="$dfile_cfgdir"/"$hash"/"$cur_template"

    mkdir -p "$dfile_cfgdir"
    mkdir -p "$build_config_path"
    mkdir -p "$run_config_path"
    mkdir -p "$cur_template_dir"

    [[ -e "$build_config_path"/"$default_build_cfg" ]] || cp "$default_cfg_template"/*.buildconfig "$build_config_path"
    [[ -e "$run_config_path"/"$default_run_cfg" ]] || cp "$default_cfg_template"/*.runconfig "$run_config_path"

    echo "$dfile" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$runfile"

    [[ -e "$cur_template_dir"/"$cur_build_cfg" ]] || cp "$build_config_path"/"$default_build_cfg" "$cur_template_dir"/"$cur_build_cfg"
    [[ -e "$cur_template_dir"/"$cur_run_cfg" ]] || cp "$run_config_path"/"$default_run_cfg" "$cur_template_dir"/"$cur_run_cfg"

    echo "$cur_template_dir"/"$cur_build_cfg" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curBuildCfg"
    echo "$cur_template_dir"/"$cur_run_cfg" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curRunCfg"

    processConfigFiles "$dfile" "$run_id" "$configoption"
}

show_config() {
    local run_id="${1}"
    local dfile="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"
    local cur_template_dir="$dfile_cfgdir"/"$hash"/"$cur_template"

    local buildTempfile=/tmp/buildConfigPath-"$(date +%N)"
    find "$build_config_path" -name "*.buildconfig" -type f | sort >"$buildTempfile"

    echo -e "______________________________________________________________________________________"
    echo -e "Configs [for dockerfile and run]"
    echo -e "______________________________________________________________________________________"

    echo -e "buildconfig >\n"
    cat "$buildTempfile" | xargs -I X echo "echo -e X:; \
                            ([[ \$(cat $cur_template_dir/$cur_build_cfg) == \$(cat X) ]] && [[ \$(cat \$(cat /tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curBuildCfg)) == \$(cat X) ]] && echo -e \\\e[32m[*d][*r] \$(cat X)\\\e[0m) || \
                            ([[ \$(cat $cur_template_dir/$cur_build_cfg) == \$(cat X) ]] && echo -e \\\e[32m[*d] \$(cat X)\\\e[0m) || \
                            ([[ \$(cat \$(cat /tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curBuildCfg)) == \$(cat X) ]] && echo -e \\\e[33m[*r] \$(cat X)\\\e[0m) || cat X; echo -e" | bash | nl -bp.*\.buildconfig

    local runTempfile=/tmp/runConfigPath-"$(date +%N)"
    find "$run_config_path" -name "*.runconfig" -type f | sort >"$runTempfile"
    echo -e "______________________________________________________________________________________"

    echo -e "runconfig >\n"
    cat "$runTempfile" | xargs -I X echo "echo -e X:; \
                            ([[ \$(cat $cur_template_dir/$cur_run_cfg) == \$(cat X) ]] && [[ \$(cat \$(cat /tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curRunCfg)) == \$(cat X) ]] && echo -e \\\e[32m[*d][*r] \$(cat X)\\\e[0m) || \
                            ([[ \$(cat $cur_template_dir/$cur_run_cfg) == \$(cat X) ]] && echo -e \\\e[32m[*d] \$(cat X)\\\e[0m) || \
                            ([[ \$(cat \$(cat /tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curRunCfg)) == \$(cat X) ]] && echo -e \\\e[33m[*r] \$(cat X)\\\e[0m) || cat X; echo -e" | bash | nl -bp.*\.runconfig

    echo -e "______________________________________________________________________________________"
}

show_config_for_dockerfile() {
    local dfile="${1}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"
    local cur_template_dir="$dfile_cfgdir"/"$hash"/"$cur_template"

    local buildTempfile=/tmp/buildConfigPath-"$(date +%N)"
    find "$build_config_path" -name "*.buildconfig" -type f | sort >"$buildTempfile"

    echo -e "______________________________________________________________________________________"
    echo -e "Configs [for dockerfile]"
    echo -e "______________________________________________________________________________________"

    echo -e "buildconfig >\n"
    cat "$buildTempfile" | xargs -I X echo "echo -e X:; \
                            ([[ \$(cat $cur_template_dir/$cur_build_cfg) == \$(cat X) ]] && echo -e \\\e[32m[*d] \$(cat X)\\\e[0m) || \
                            cat X; echo -e" | bash | nl -bp.*\.buildconfig

    local runTempfile=/tmp/runConfigPath-"$(date +%N)"
    find "$run_config_path" -name "*.runconfig" -type f | sort >"$runTempfile"
    echo -e "______________________________________________________________________________________"

    echo -e "runconfig >\n"
    cat "$runTempfile" | xargs -I X echo "echo -e X:; \
                            ([[ \$(cat $cur_template_dir/$cur_run_cfg) == \$(cat X) ]] && echo -e \\\e[32m[*d] \$(cat X)\\\e[0m) || \
                            cat X; echo -e" | bash | nl -bp.*\.runconfig

    echo -e "______________________________________________________________________________________"
}

build_config_template() {
    local run_id="${1}"

    cur_build_cfg_file="/tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curBuildCfg"
    cat "$cur_build_cfg_file"
}

run_config_template() {
    local run_id="${1}"

    cur_run_cfg_file="/tmp/$dockerassist_root_dir/$rundata_dir/$run_id/$curRunCfg"
    cat "$cur_run_cfg_file"
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
        replace "$container_pholder" ${cfgmap_ref[$container_pholder]} |
        replace "$cmd_pwd_pholder" ${cfgmap_ref[$cmd_pwd_pholder]}
}

buildcfg_builder() {
    local run_id="${1}"
    local -n build_cfgmap_ref=${2}
    cfg_builder "$(build_config_template $run_id)" build_cfgmap_ref
}

runcfg_builder() {
    local run_id="${1}"
    local -n run_cfgmap_ref=${2}
    cfg_builder "$(run_config_template $run_id)" run_cfgmap_ref
}

updateBuildConfigFiles() {
    local build_config_path="${1}"
    local run_id="${2}"

    local build_cfg_file=
    local tempfile=/tmp/buildConfigPath-"$(date +%N)"

    find "$build_config_path" -name "*.buildconfig" -type f | sort >"$tempfile"

    count_of_buildConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_buildConfigs == 0)) && echo -e "No .buildconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_buildConfigs == 1)); then
        build_cfg_file="$(cat "$tempfile")"
        echo "$build_cfg_file"
    else
        echo -e "______________________________________________________________________________________"
        echo -e "Multiple .buildconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .buildconfig to choose? Enter the number (press ENTER for no change): " no
        [[ "$no" ]] && build_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        # echo "$build_cfg_file"
    fi

    rm "$tempfile"
    [[ ! "$build_cfg_file" ]] && echo -e "Keeping the current selection" && return 0

    editor -w "$build_cfg_file"
    echo "$build_cfg_file" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curBuildCfg"
    return 0
}

updateRunConfigFiles() {
    local run_config_path="${1}"
    local run_id="${2}"

    local run_cfg_file=
    local tempfile=/tmp/runConfigPath-"$(date +%N)"

    find "$run_config_path" -name "*.runconfig" -type f | sort >"$tempfile"

    count_of_runConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_runConfigs == 0)) && echo -e "No .runconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_runConfigs == 1)); then
        run_cfg_file="$(cat "$tempfile")"
        echo "$run_cfg_file"
    else
        echo -e "______________________________________________________________________________________"
        echo -e "Multiple .runconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .runconfig to choose? Enter the number (press ENTER for no change): " no
        [[ "$no" ]] && run_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        # echo "$run_cfg_file"
    fi

    rm "$tempfile"
    [[ ! "$run_cfg_file" ]] && echo -e "Keeping the current selection" && return 0

    editor -w "$run_cfg_file"
    echo "$run_cfg_file" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curRunCfg"
    return 0
}

updateConfigFiles() {
    local dfile="${1}"
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"

    updateBuildConfigFiles "$build_config_path" "$run_id"
    updateRunConfigFiles "$run_config_path" "$run_id"
}

updateCurrentBuildConfigFile() {
    local build_config_path="${1}"
    local run_id="${2}"
    local cur_template_dir="${3}"

    local build_cfg_file=
    local tempfile=/tmp/currentBuildConfigPath-"$(date +%N)"

    find "$build_config_path" -name "*.buildconfig" -type f | sort >"$tempfile"

    count_of_buildConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_buildConfigs == 0)) && echo -e "No .buildconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_buildConfigs == 1)); then
        build_cfg_file="$(cat "$tempfile")"
        echo "$build_cfg_file"
    else
        echo -e "______________________________________________________________________________________"
        echo -e "Multiple .buildconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .buildconfig to choose? Enter the number (press ENTER for no change): " no
        [[ "$no" ]] && build_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        # echo "$build_cfg_file"
    fi

    rm "$tempfile"
    [[ ! "$build_cfg_file" ]] && echo -e "Keeping the current selection" && return 0

    editor -w "$build_cfg_file"

    cat "$build_cfg_file" >"$cur_template_dir"/"$cur_build_cfg"
    echo "$cur_template_dir"/"$cur_build_cfg" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curBuildCfg"
    return 0
}

updateCurrentRunConfigFile() {
    local run_config_path="${1}"
    local run_id="${2}"
    local cur_template_dir="${3}"

    local run_cfg_file=
    local tempfile=/tmp/currentRunConfigPath-"$(date +%N)"

    find "$run_config_path" -name "*.runconfig" -type f | sort >"$tempfile"

    count_of_runConfigs=$(cat "$tempfile" | wc -l)

    ((count_of_runConfigs == 0)) && echo -e "No .runconfig found in the current directory hierarchy. Exiting." && return 1

    if ((count_of_runConfigs == 1)); then
        run_cfg_file="$(cat "$tempfile")"
        echo "$run_cfg_file"
    else
        echo -e "______________________________________________________________________________________"
        echo -e "Multiple .runconfig found in the current directory hierarchy!"
        cat "$tempfile" | xargs -I X echo "echo -e X: \$(cat X)" | bash | nl

        read -p "Which .runconfig to choose? Enter the number (press ENTER for no change): " no
        [[ "$no" ]] && run_cfg_file=$(cat "$tempfile" | nl | head -n$no | tail -n1 | cut -f2)
        # echo "$run_cfg_file"
    fi

    rm "$tempfile"
    [[ ! "$run_cfg_file" ]] && echo -e "Keeping the current selection" && return 0

    editor -w "$run_cfg_file"

    cat "$run_cfg_file" >"$cur_template_dir"/"$cur_run_cfg"
    echo "$cur_template_dir"/"$cur_run_cfg" >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curRunCfg"
    return 0
}

updateCurrentConfigFiles() {
    local dfile="${1}"
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"
    local cur_template_dir="$dfile_cfgdir"/"$hash"/"$cur_template"

    updateCurrentBuildConfigFile "$build_config_path" "$run_id" "$cur_template_dir"
    updateCurrentRunConfigFile "$run_config_path" "$run_id" "$cur_template_dir"
}

createConfigFiles() {
    local dfile="${1}"
    local run_id="${2}"

    local hash=$(echo "$dfile" | md5sum | cut -f1 -d' ')
    local dfile_cfgdir=/tmp/"$dockerassist_root_dir"/"$config_dir"
    local build_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$build_config_dir"
    local run_config_path="$dfile_cfgdir"/"$hash"/"$config_templates"/"$run_config_dir"

    local bfile=
    local rfile=

    echo -e "Creating new confiuration files:"

    echo -e "<<.buildconfig>>"
    read -p "Enter only the name of the new .buildconfig file (do not provide the extension) > " bfile
    editor -w "$build_config_path"/"$bfile".buildconfig
    echo "$build_config_path"/"$bfile".buildconfig >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curBuildCfg"

    echo -e "<<.runconfig>>"
    read -p "Enter only the name of the new .runconfig file (do not provide the extension) > " rfile
    editor -w "$run_config_path"/"$rfile".runconfig
    echo "$run_config_path"/"$rfile".runconfig >/tmp/"$dockerassist_root_dir"/"$rundata_dir"/"$run_id"/"$curRunCfg"
}

cleanConfig() {
    echo -e "______________________________________________________________________________________"
    echo -e "CLEANING ALL CONFIGS"
    echo -e "______________________________________________________________________________________"
    read -p "Will delete all configs. Do you want to proceed? (y)es/(n)o > " ans
    ans=$(echo "$ans" | tr [:upper:] [:lower:])
    [[ "$ans" == "y" ]] && rm -rf /tmp/"$dockerassist_root_dir"/"$dfstepper_dir" && echo -e "Removed all configs and runs."
}
