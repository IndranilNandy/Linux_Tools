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
staged="$dotenv_loc"/staged
help_dir="$curDir"/env/secrets/dotenv/help

sync() {
    [[ -d "$dotenv_loc"/remote ]] && rm -rf "$dotenv_loc"/remote
    mkdir -p "$dotenv_loc"/remote
    mkdir -p "$dotenv_loc"/global

    echo -e
    echo -e "----------------------------------------------------------"
    echo -e "(sync)\tgit-store ---> copying to ---> remote"
    echo -e "----------------------------------------------------------"

    echo -e "${YELLOW}Files in 'remote' scope are read-only.${RESET}"
    cp "$remote_store"/.env.gpg "$dotenv_loc"/remote
    cp "$remote_store"/.env.def "$dotenv_loc"/remote/.env.def.original
    gpg -o "$dotenv_loc"/remote/.env.original --decrypt "$dotenv_loc"/remote/.env.gpg
    echo -e "\n${GREEN}Copied${RESET}"

    echo -e
    echo -e "----------------------------------------------------------"
    echo -e "(sync)\tremote ---> copying to ---> global"
    echo -e "----------------------------------------------------------"
    echo -e "${YELLOW}Files in system 'global' scope are writable.${RESET} ${RED}\nBUT BE CAUTIOUS! CHANGING THESE FILES WILL CHANGE THE STORE-COPY REFERRED BY ALL PROJECTS!\n${RESET}"

    if [[ -f "$dotenv_loc"/global/.env ]]; then
        echo -e "${YELLOW}.env -> Already exists in 'global' scope. NOT UPDATING${RESET}"
    else
        cp "$dotenv_loc"/remote/.env.original "$dotenv_loc"/global/.env
        echo -e ".env -> ${GREEN}Copied${RESET}"
    fi

    if [[ -f "$dotenv_loc"/global/.env.def ]]; then
        echo -e "${YELLOW}.env.def -> Already exists in 'global' scope. NOT UPDATING${RESET}"
    else
        cp "$dotenv_loc"/remote/.env.def.original "$dotenv_loc"/global/.env.def
        echo -e ".env.def -> ${GREEN}Copied${RESET}"
    fi

    case "${1}" in
    --f)
        echo -e "\nYou have used '--f' option to force 'sync'. \n${RED}This will override your global scopped env files, and will affect each project while fetch env template from 'global' scope.${RESET}"
        read -p "Do you want to override 'global' scopped files? [y/n]..." ans

        if [[ $(echo "$ans" | tr [:upper:] [:lower:]) == "y" ]]; then
            echo -e
            echo -e "Overriding .env file" && cp -i "$dotenv_loc"/remote/.env.original "$dotenv_loc"/global/.env
            echo -e "Overriding .env.def file" && cp -i "$dotenv_loc"/remote/.env.def.original "$dotenv_loc"/global/.env.def
        else
            echo -e "NOT overriding!"
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
        echo -e "${RED}'global' scope doesn't yet exist. \nHence using 'sync' command to create 'remote' scope and then populate 'global' scope.${RESET}"
        sync
    fi

    echo -e
    echo -e "----------------------------------------------------------"
    echo -e "(load)\tglobal ---> copying to ---> local"
    echo -e "----------------------------------------------------------"
    echo -e "Verify and update the locally loaded '.env'. ${YELLOW}\nNote. You need to run this command from your project root directory.${RESET}"
    echo -e "Also opening '.env.def' file for your reference."

    # REMEMBER: For safety reason, you can NEVER override a local .env once it is created, you can merge it with updated 'global' copy using 'merge' command
    if [[ -f "$local_env" ]]; then
        echo -e "${RED}\nA local scopped '.env' file already exists. Instead of fetcing from 'global' scope, opening the local copy.${RESET}\n${GREEN}For safety reason, you can NEVER override a local .env once it is created, you can merge it with updated 'global' copy using 'merge' command.${RESET}"
    else
        cp "$global_env" "$(pwd)"
        echo -e "\n${GREEN}Copied${RESET}"
    fi

    editor "$global_env_def"
    echo -e "\nUpdate, save and close .env before proceeding."
    editor -w "$local_env"
}

remotescope() {
    echo -e "These are read-only."
    editor "$dotenv_loc"/remote/.env.original
    editor "$dotenv_loc"/remote/.env.def.original
}

globalscope() {
    echo -e "${RED}[WARNING!] BE CAUTIOUS BEFORE CHANGING. THIS WILL CHANGE THE STORE-COPY REFERRED BY ALL PROJECTS!${RESET}"
    editor "$global_env"
    editor "$global_env_def"
}

localscope() {
    [[ -f "$(pwd)"/.env ]] && editor "$(pwd)"/.env || echo -e "${RED}No .env file exists in current directory. You should run this command from the project root directory.${RESET}"
}

show() {
    case "${1}" in
    --remote)
        echo -e "----------------------------------------------------------"
        echo -e "(show)\tShowing remote"
        echo -e "----------------------------------------------------------"
        remotescope
        ;;
    --global)
        echo -e "----------------------------------------------------------"
        echo -e "(show)\tShowing global"
        echo -e "----------------------------------------------------------"
        globalscope
        ;;
    --local)
        echo -e "----------------------------------------------------------"
        echo -e "(show)\tShowing local"
        echo -e "----------------------------------------------------------"
        localscope
        ;;
    *)
        echo -e "----------------------------------------------------------"
        echo -e "(show)\tShowing global (Default)"
        echo -e "----------------------------------------------------------"
        globalscope
        ;;
    esac
}

merge() {
    echo -e "Ensure that you've local scopped .env file. Otherwise, it wouldn't do anything since nothing to merge."

    [[ -f "$(pwd)/.env" ]] && echo -e "Merging .env" && p4merge -nb "Scope:REMOTE" -nl "Scope:GLOBAL" -nr "Scope:LOCAL" -nm "Scope:LOCAL(merged)" "$dotenv_loc/remote/.env.original" "$dotenv_loc/global/.env" "$(pwd)/.env" "$(pwd)/.env" 2>/dev/null
    [[ -f "$dotenv_loc/global/.env.def" ]] && echo -e "Merging .env.def" && p4merge -nb "IGNORE THIS" -nl "Scope:REMOTE" -nr "Scope:GLOBAL" -nm "Scope:GLOBAL(merged)" "$dotenv_loc/remote/.env.def.original" "$dotenv_loc/global/.env.def" "$dotenv_loc/global/.env.def" 2>/dev/null
}

encrypt() {
    echo -e "----------------------------------------------------------"
    echo -e "(encrypt)\tglobal ---> encrypting to ---> staged"
    echo -e "----------------------------------------------------------"

    target_dir="$staged"/"$(date +%4Y-%m-%d@%H:%M:%S)"
    mkdir -p "$target_dir"

    echo -e "This will encrypt only .env file in the system global scope. \
    \nEncrypted .env and unencrypted .env.def from 'global' scope will be stored in 'staged' folder. \
    \n${GREEN}Push these two files manually to remote git-store.\nLocation: $target_dir${RESET}"
    echo -e "${RED}Remember the password used to encrypt. You should use the same password you always use.${RESET}"

    gpg -o "$target_dir"/.env.gpg --symmetric "$global_env" || return 1
    cp "$global_env_def" "$target_dir"/
    echo -e "\n${GREEN}Staged successfully${RESET}"
}

help() {
    cat "$help_dir"/dotenv_configurer.help
}

case "${1}" in
sync)
    echo -e "______________________________________________________________________________________"
    echo -e "[Dotenv] SYNC"
    echo -e "______________________________________________________________________________________"
    sync "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
load)
    echo -e "______________________________________________________________________________________"
    echo -e "[Dotenv] LOAD"
    echo -e "______________________________________________________________________________________"
    load "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
show)
    echo -e "______________________________________________________________________________________"
    echo -e "[Dotenv] SHOW"
    echo -e "______________________________________________________________________________________"
    show "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
merge)
    echo -e "______________________________________________________________________________________"
    echo -e "[Dotenv] MERGE"
    echo -e "______________________________________________________________________________________"
    merge "${@:2}"
    echo -e "______________________________________________________________________________________"
    ;;
encrypt)
    echo -e "______________________________________________________________________________________"
    echo -e "[Dotenv] ENCRYPT"
    echo -e "______________________________________________________________________________________"
    encrypt "${@:2}" || echo -e "${RED}\nFailed!${RESET}"
    echo -e "______________________________________________________________________________________"
    ;;
help)
    help "${@:2}"
    ;;
*)
    help "${@:2}"
    ;;
esac
