#!/usr/bin/env bash

[[ -n "$LINUX_TOOLS_full_installation" ]] || . ./../../../../.systemConfig

create_repodir() {
    echo -e "Nexus Repo: $LINUX_TOOLS_nexus_repo"
    [[ -d "$LINUX_TOOLS_nexus_repo" ]] || mkdir -p "$LINUX_TOOLS_nexus_repo" && sudo chown -R 200 "$LINUX_TOOLS_nexus_repo"
}

setup_nexus() {
    echo -e "[Nexus] Setting up Sonatype Nexus Repository OSS"
    docker compose -f "$(pwd)/nexus-docker-compose.yaml" up -d
    echo -e "[Nexus] Done."
}

show_admin_cred() {
    echo -e "[Nexus] Default admin credentials:"
    echo -e "\tuser: admin"
    echo -e "\tpassword: " "$(sudo docker exec -it $(basename $(pwd))-nexus-1 cat /nexus-data/admin.password)"
    echo -e "[Nexus] DO NOT FORGET to change the default credential after you sign in the portal [http://localhost:8082/]"
}

create_repodir
setup_nexus
show_admin_cred
