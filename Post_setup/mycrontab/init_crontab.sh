#!/usr/bin/env bash

if [[ -L $(which mycrontab) ]]; then
    curDir="$(dirname "$(tracelink mycrontab)")"
else
    curDir="$(pwd)"
fi

allow_user_to_cron() {
    grep -q "${1}" /etc/cron.allow || echo "${1}" | sudo tee -a /etc/cron.allow
}

generate_script() {
    cat <<EOF >"${2}"
#!/bin/bash

{
    ${1}
} >> "$(dirname "${1}")/../cronlogs/$(basename "${1}" .sh)".log
EOF
}

handle_root_user() {
    def="${1}"

    # Form generated script's name
    script_path=$(echo "$def" | awk '{ print $NF }')
    gen_script_path=$(dirname "$script_path")/generated/"$(basename "$script_path")"

    # Generate script
    generate_script "$script_path" "$gen_script_path"
    def=$(echo "$def" | sed "s#$script_path#$gen_script_path#")

    grep -q -F "$def" /tmp/crontab-"$user" || /bin/echo "$def" >>/tmp/crontab-"$user"
}

# NOTE: Cannot have same job definition for more than one users. Do we really need it?
# Anyways, different schedule for the same job will be treated as different job definitions and thus, can be assigned to two different users.
add_job_to_cron() {
    user="${1}"
    def="${2}"

    [[ "$user" == "root" ]] && handle_root_user "$def" && return 0

    # Form generated script's name
    script_path=$(echo "$def" | awk '{ print $NF }')
    gen_script_path=$(dirname "$script_path")/generated/"$(basename "$script_path")"

    # Generate script
    generate_script "$script_path" "$gen_script_path"
    def=$(echo "$def" | sed "s#$script_path#$gen_script_path#")

    grep -q -F "$def" /tmp/crontab-"$user" || /bin/echo "$def" >>/tmp/crontab-"$user"
}

create_job_definition() {
    allow_user_to_cron "${1}"
    add_job_to_cron "${1}" "${2}"
}

create_crontab() {

    grep -v "^$" /etc/cron.allow | while IFS= read -r user; do
        [[ -f /tmp/crontab-"$user" ]] || touch /tmp/crontab-"$user"
    done

    grep -v "^ *#" -h "$curDir"/.crontabs/.crontab-* | grep -v "^$" | while IFS= read -r line; do
        user=$(echo "$line" | tr -s ' ' | cut -f1 -d' ')
        def=$(echo "$line" | tr -s ' ' | cut -f2- -d' ' | sed "s#\$HOME#$HOME#")

        [[ -f /tmp/crontab-"$user" ]] || touch /tmp/crontab-"$user"
        create_job_definition "$user" "$def"
    done

    grep -v "^$" /etc/cron.allow | while IFS= read -r user; do
        if [ "$user" == "root" ]; then
            sudo crontab /tmp/crontab-"$user"
        else
            crontab -u "$user" /tmp/crontab-"$user"
        fi
        [[ ! -f /tmp/crontab-"$user" ]] || rm /tmp/crontab-"$user"
    done
}

create_crontab
