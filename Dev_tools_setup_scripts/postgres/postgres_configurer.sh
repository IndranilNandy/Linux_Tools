#!/usr/bin/env bash

role_admin="admin"
passwd=
port="5432"
db="postgres"
db_init_admin="postgres"

# WHY DO YOU NEED TO CREATE A SEPARATE SUPERUSER role/user?
# To import a sql file to initialize db, you need to use scram authentication, otherwise you'll get 'permission denied' error becuase of ownership issues
# psql <connection_cmd> -f init.sql / psql <connection_cmd> < init.sql
# connection_cmd: -U <user> -d <db> (for local connection) OR connection_cmd: postgresql://<user>@localhost:5432/<db> (for host connection)
# For both local and host connection, we need to use scram (or others except peer) authentication
# Now, we should not use default'postgres' user with scram auth
# By default, 'local all postgres peer' is used, since on initial setup we wouldn't have password setup for 'postgres' user, so we have to login using 'postgres' with 'peer' auth
# So, we'll create another role/user as SUPERUSER (for CREATE etc permission) and configure its authentication with 'scram' (check updated pg_hba.config in Linux_Tools)
# To import any .sql script, you may use this role/user
create_admin_role() {
    echo -e "Creating new admin role: <$role_admin>"
    read -p "Enter password for new admin role <$role_admin>: " -s passwd

    sudo su -c "psql -c \"create user $role_admin with SUPERUSER PASSWORD '$passwd';\" -c '\du' -c '\l'" "$db_init_admin" || return 1
    return 0
}

init_db() {
    echo -e "Logging in as <$role_admin> and initializing db"
    psql postgresql://"$role_admin"@localhost:"$port"/"$db" <'./dbinit_scripts/init.sql'
}

read -p "Want to proceed with Postgres configuration and db initialization? [Y/N]" reply
[[ "$reply" == "Y" ]] || [[ "$reply" == "y" ]] || exit 1

create_admin_role && init_db || echo -e "[Error] Configuration failed"
