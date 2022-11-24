#!/usr/bin/env bash

if [[ -L $(which mycrontab) ]]; then
    curDir="$(dirname "$(tracelink mycrontab)")"
else
    curDir="$(pwd)"
fi

edit_config() {
    editor -w "$curDir"/.crontabs/.crontab-*
    schedule
}

schedule() {
    "$curDir"/init_crontab.sh
}

new_job_editor() {
    script_name=$(echo "${1}" | awk -F"=" '{ print $2 }')
    echo -e "Adding new job script: $script_name"
    editor -w "$curDir"/cronjobs/"$script_name" &
    echo -e "'mycrontab --config': run this command to edit the crontab configs and schedule new job"
}

add_new_job_from_path() {
    script_path=$(echo "${1}" | awk -F"=" '{ print $2 }')
    script_name=$(basename "$script_path")

    [[ -f "$curDir"/cronjobs/"$script_name" ]] && echo -e "Filename already exists. Change script name." && return 1
    cp "$script_path" "$curDir"/cronjobs/"$script_name"
    echo "Added new job script: $script_name"
    echo -e "'mycrontab --config': run this command to edit the crontab configs and schedule new job"
}

show_users() {
    sudo cat /etc/cron.allow
}

show_jobs() {
    case "${1}" in
    -a)
        grep -v "^ *#" -h "$curDir"/.crontabs/.crontab-* | grep -v "^$"
        ;;
    -u=*)
        user=$(echo "${1}" | awk -F"=" '{ print $2 }')
        grep -v "^ *#" -h "$curDir"/.crontabs/.crontab-* | grep -v "^$" | grep "$user"
        ;;
    esac
}

backup_jobs() {
    case "${1}" in
    -mycron-def)
        dest_dir="$curDir"/cronbackups/mycron-defs/"$(date +%F:%H:%M:%S)"
        mkdir -p "$dest_dir"
        cp "$curDir"/.crontabs/.crontab-* "$dest_dir"
        echo -e "Backup location [mycrontab def]: $dest_dir"
        ;;
    -cron-def)
        dest_file="$curDir"/cronbackups/cron-defs/backup-"$(date +%F:%H:%M:%S)"
        touch "$dest_file"

        grep -v "^$" /etc/cron.allow | while IFS= read -r user; do
            if [ "$user" == "root" ]; then
                sudo crontab -l | xargs -I ENTRY echo "echo \"$user ENTRY\" >> $dest_file" | bash
            else
                crontab -u "$user" -l | xargs -I ENTRY echo "echo \"$user ENTRY\" >> $dest_file" | bash
            fi
        done
        echo -e "Backup location [crontab def]: $dest_file"
        ;;

    esac
}

clean_jobs() {
    case "${1}" in
    -a)
        sudo cat /etc/cron.allow | xargs -I USER echo "gawk -i inplace ' \$1!=\"USER\" ' "$curDir"/.crontabs/.crontab-*; echo -e Jobs cleaned for user USER" | bash
        ;;
    -u=*)
        user=$(echo "${1}" | awk -F"=" '{ print $2 }')
        gawk -i inplace -v user="$user" ' $1!=user ' "$curDir"/.crontabs/.crontab-*
        echo -e "Jobs cleaned for user $user"
        ;;
    esac
}

clean_logs() {
    rm "$curDir"/cronbackups/cron-defs/backup-* 2> /dev/null
    find "$curDir"/cronbackups/mycron-defs/. ! -name '.' -type d -exec rm -rf {} \; 2> /dev/null
}

show_logs() {
    editor -w "$curDir"/cronlogs/ &
}

show_backups() {
    editor -w "$curDir"/cronbackups/ &
}

show_help() {
    cat "$curDir"/help/mycrontab.help
}

case ${1} in
--config)
    edit_config
    echo -e "Crontabs configured and jobs scheduled"
    ;;
--schedule)
    schedule
    echo -e "All the jobs scheduled"
    ;;
++job-name=*)
    new_job_editor "${1}"
    ;;
++job-path=*)
    add_new_job_from_path "${1}"
    ;;
--users)
    show_users
    ;;
--jobs)
    [[ -n "${2}" ]] || (echo -e "Missing second argument" && exit 1)
    show_jobs "${2}"
    ;;
--backup)
    backup_jobs "${2}"
    echo -e "Completed backing all existing jobs"
    ;;
--show-logs)
    show_logs
    ;;
--show-backups)
    show_backups
    ;;
--clean)
    [[ -n "${2}" ]] || (echo -e "Missing second argument" && exit 1)
    mycrontab --backup -mycron-def
    mycrontab --backup -cron-def
    clean_jobs "${2}"
    schedule
    ;;
--clean-logs)
    clean_logs
    echo -e "All logs cleaned"
    ;;
--help)
    show_help
    ;;
*)
    show_help
    ;;
esac
