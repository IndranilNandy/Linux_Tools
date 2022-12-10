#!/usr/bin/env bash

clean_log() {
    echo -e "Analysing /var/log"
    sudo du -sh /var/log

    echo -e "Top 10 sizes:"
    sudo du /var/log | sort -nr | head -n10
    echo -e

    journalctl --disk-usage
    echo -e "Rotating journal files"
    sudo journalctl --rotate
    echo -e "Deleting journal logs older than 2 days"
    sudo journalctl --vacuum-time=2days
    echo -e "Remove manually."
    echo -e
}

apt_cleaner() {
    echo -e "[APT] Removing unwanted dependencies and cache"
    sudo du -sh /var/cache/apt

    sudo apt-get autoremove
    sudo apt-get clean
    echo -e
}

clean_cache() {
    echo -e "Analysing /home/indranilnandy/.cache"
    sudo du -sh "/home/indranilnandy"/.cache
    echo -e "Top 10 sizes:"
    du "/home/indranilnandy"/.cache | sort -nr | head -n10
    echo -e "Remove manually."
    echo -e
}

clean_temp() {
    echo -e "Analysing /tmp"
    sudo du -sh /tmp
    echo -e "Top 10 sizes:"
    sudo du /tmp | sort -nr | head -n10
    echo -e "Remove manually."
    echo -e
}

echo "Running script" | ts '[%Y-%m-%d %H:%M:%S]'
echo -e "Cleaning Ubuntu system"
echo -e

clean_log
apt_cleaner
clean_cache
clean_temp

echo "Completed script." | ts '[%Y-%m-%d %H:%M:%S]'

echo "#####################DONE#####################"
echo
