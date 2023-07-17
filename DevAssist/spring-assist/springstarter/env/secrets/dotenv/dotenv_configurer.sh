#!/usr/bin/env bash

if [ -L "$(which springstarter)" ]; then
    curDir="$(dirname "$(tracelink springstarter)")"
else
    curDir="$(pwd)"
fi

remote_store="$LINUX_TOOLS_spring_helper"/Env/dotenv
dotenv_loc="$LINUX_TOOLS_scrtstore"/dotenv
global_env="$dotenv_loc"/global/.env
global_env_def="$dotenv_loc"/global/.env.def
local_env="$(pwd)"/.env
vers="$dotenv_loc"/versions_to_push
help_dir="$curDir"/env/secrets/dotenv/help

sync() {
    [[ -d "$dotenv_loc"/remote ]] && rm -rf "$dotenv_loc"/remote
    mkdir -p "$dotenv_loc"/remote
    mkdir -p "$dotenv_loc"/global

    echo -e "Fetching remote copies from git-store and storing in a folder named 'remote'"
    echo -e "${YELLOW}Files in 'remote' scope are read-only.${RESET}"
    cp "$remote_store"/.env.gpg "$dotenv_loc"/remote
    cp "$remote_store"/.env.def "$dotenv_loc"/remote/.env.def.original
    gpg -o "$dotenv_loc"/remote/.env.original --decrypt "$dotenv_loc"/remote/.env.gpg

    echo -e "\nCopying 'remote' scopped env files to system 'global' scope in a folder named 'global'"
    echo -e "${YELLOW}Files in system 'global' scope are writable.${RESET} ${RED}\nBUT BE CAUTIOUS! CHANGING THESE FILES WILL CHANGE THE STORE-COPY REFERRED BY ALL PROJECTS!\n${RESET}"

    [[ -f "$dotenv_loc"/global/.env ]] && echo -e "${YELLOW}[.env] Already exists in 'global' scope. NOT UPDATING${RESET}" || cp "$dotenv_loc"/remote/.env.original "$dotenv_loc"/global/.env
    [[ -f "$dotenv_loc"/global/.env.def ]] && echo -e "${YELLOW}[.env.def] Already exists in 'global' scope. NOT UPDATING${RESET}" || cp "$dotenv_loc"/remote/.env.def.original "$dotenv_loc"/global/.env.def

    case "${1}" in
    --f)
        echo -e "You have used '--f' option to force 'sync'. \n${RED}This will override your global scopped env files, and will affect each project while fetch env template from 'global' scope.${RESET}"
        read -p "Do you want to override 'global' scopped files? [y/n]..." ans

        if [[ $(echo "$ans" | tr [:upper:] [:lower:]) == "y" ]]; then
            echo -e "Overriding .env file" && cp -i "$dotenv_loc"/remote/.env.original "$dotenv_loc"/global/.env
            echo -e "Overriding .env.def file" && cp -i "$dotenv_loc"/remote/.env.def.original "$dotenv_loc"/global/.env.def
        fi

        ;;
    *) ;;
    esac

    chmod 444 "$dotenv_loc"/remote/.env.def.original
    chmod 444 "$dotenv_loc"/remote/.env.original
}

load() {
    if [[ -f "$global_env" ]]; then
        echo -e "'global' scope already created. Hence NOT updating it."
    else
        echo -e "${RED}'global' scope doesn't yet exist. Hence using 'sync' command to create 'remote' scope and then populate 'global' scope.${RESET}"
        sync
    fi

    echo -e "[Env][Dotenv] Fetching '.env' file from system 'global' scope to your local scopped current directory. Verify and update accordingly. ${YELLOW}\nNote. You need to run this command from your project root directory.${RESET}"
    echo -e "\nAlso opening '.env.def' file for your reference."

    # REMEMBER: For safety reason, you can NEVER override a local .env once it is created, you can merge it with updated 'global' copy using 'merge' command
    [[ -f "$local_env" ]] && echo -e "${RED}A local scopped '.env' file already exists. Instead of fetcing from 'global' scope, opening the local copy.${RESET}\n${GREEN}For safety reason, you can NEVER override a local .env once it is created, you can merge it with updated 'global' copy using 'merge' command.${RESET}" || cp "$global_env" "$(pwd)"
    editor "$global_env_def"
    echo -e "Update, save and close .env before proceeding."
    editor -w "$local_env"
}

remotescope() {
    echo -e "[Env][Dotenv] Showing 'remote' scopped env files. These are read-only."
    editor "$dotenv_loc"/remote/.env.original
    editor "$dotenv_loc"/remote/.env.def.original
}

globalscope() {
    echo -e "[Env][Dotenv] Showing 'global' scopped env files. ${RED}\n[WARNING!] BE CAUTIOUS BEFORE CHANGING. THIS WILL CHANGE THE STORE-COPY REFERRED BY ALL PROJECTS!${RESET}"
    editor "$global_env"
    editor "$global_env_def"
}

localscope() {
    [[ -f "$(pwd)"/.env ]] && echo -e "[Env][Dotenv] Showing 'local' scopped .env file" && editor "$(pwd)"/.env || echo -e "${RED}No .env file exists in current directory. You should run this command from the project root directory.${RESET}"
}

show() {
    case "${1}" in
    --remote)
        remotescope
        ;;
    --global)
        globalscope
        ;;
    --local)
        localscope
        ;;
    *)
        globalscope
        ;;
    esac
}

merge() {
    echo -e "Ensure that you've local scopped .env file. Otherwise, it wouldn't do anything since nothing to merge."
    echo -e "Showing .env"
    p4merge -nb "Scope:REMOTE" -nl "Scope:GLOBAL" -nr "Scope:LOCAL" -nm "Scope:LOCAL(merged)" "$dotenv_loc/remote/.env.original" "$dotenv_loc/global/.env" "$(pwd)/.env" "$(pwd)/.env" 2> /dev/null

    echo -e "Showing .env.def"
    p4merge -nb "IGNORE THIS" -nl "Scope:REMOTE" -nr "Scope:GLOBAL" -nm "Scope:GLOBAL(merged)" "$dotenv_loc/remote/.env.def.original" "$dotenv_loc/global/.env.def" "$dotenv_loc/global/.env.def" 2> /dev/null

}

encrypt() {
    target_dir="$vers"/"$(date +%4Y-%m-%d@%H:%M:%S)"
    mkdir -p "$target_dir"

    echo -e "[Env][Dotenv] This will encrypt only .env file in the system global scope. \
    \nEncrypted .env and unencrypted .env.def from 'global' scope will be stored in 'versions_to_push' folder. \
    \n${GREEN}Push these two files manually to remote git-store.\nLocation: $target_dir${RESET}"
    echo -e "${RED}Remember the password used to encrypt. You should use the same password you always use.${RESET}"

    gpg -o "$target_dir"/.env.gpg --symmetric "$global_env"
    cp "$global_env_def" "$target_dir"/
}

help() {
    cat "$help_dir"/dotenv_configurer.help
}

case "${1}" in
sync)
    sync "${@:2}"
    ;;
load)
    load "${@:2}"
    ;;
show)
    show "${@:2}"
    ;;
merge)
    merge "${@:2}"
    ;;
encrypt)
    encrypt "${@:2}"
    ;;
help)
    help "${@:2}"
    ;;
*)
    help "${@:2}"
    ;;
esac
