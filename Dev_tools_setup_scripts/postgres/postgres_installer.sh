#!/usr/bin/env bash

# Ref. https://wiki.postgresql.org/wiki/Apt
install_postgresql() {
    sudo apt install curl ca-certificates gnupg
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

    # sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    # wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql
}

ifinstalled postgresql > /dev/null || install_postgresql || echo -e "[Error] Postgres installation failed. Exiting..."
ifinstalled postgresql > /dev/null || exit 1
# Configurer is called from the interactive setup script when Full Setup of Linux_Tools is going
[[ -n "$LINUX_TOOLS_full_installation" ]] || ./postgres_configurer.sh

ifinstalled pgadmin4 || ./gui_tools/pgadmin4/pgadmin4_installer.sh

# Configurer is called from the interactive setup script when Full Setup of Linux_Tools is going
[[ -n "$LINUX_TOOLS_full_installation" ]] || (./gui_tools/pgadmin4/pgadmin4_web_configurer.sh && echo -e "Launching pgadmin4. Change File -> Preferences -> Miscellaneous -> Themes" && /usr/pgadmin4/bin/pgadmin4)

ifinstalled dbeaver || ./gui_tools/dbeaver/dbeaver_installer.sh

ifinstalled omnidb || ./gui_tools/omnidb/omnidb_installer.sh

# Configurer is called from the interactive setup script when Full Setup of Linux_Tools is going
ifinstalled squirrel || [[ -n "$LINUX_TOOLS_full_installation" ]] || (./gui_tools/squirrel/squirrel_installer.sh)
[[ -n "$LINUX_TOOLS_full_installation" ]] || (./gui_tools/squirrel/squirrel_configurer.sh)
