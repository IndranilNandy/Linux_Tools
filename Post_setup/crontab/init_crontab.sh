#!/usr/bin/env bash

if [[ -L $(which mycrontab) ]]; then
    curDir="$(dirname "$(tracelink mycrontab)")"
else
    curDir="$(pwd)"
fi

init() {
    [[ -f /etc/cron.allow ]] || sudo touch /etc/cron.allow
    grep -q "root" /etc/cron.allow || echo "root" | sudo tee -a /etc/cron.allow
    grep -q "$(whoami)" /etc/cron.allow || whoami | sudo tee -a /etc/cron.allow
}

create_job_definition() {
    user="${1}"
    def="${2}"
}

create_crontab() {
    grep -v "^ *#" "$curDir"/.crontab | while IFS= read -r line
    do
        # echo -e abc "$line"
        user=$(echo "$line" | cut -f1 -d' ')
        def=$(echo "$line" | cut -f2- -d' ')
        echo "$user"
        echo "$def"
    done
}

init
create_crontab