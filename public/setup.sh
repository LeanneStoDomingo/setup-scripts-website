#!/usr/bin/env bash

# inspired by:
# https://github.com/markflorkowski/markflorkowski/blob/main/public/setup.sh

# color values:
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
Color_Off='\033[0m'
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BBlue='\033[1;34m'

# TODO: make $1 the name of the color var so switch case isn't needed (ex: print_color BGreen "hello world")
# https://stackoverflow.com/questions/1921279/how-to-get-a-variable-value-if-variable-name-is-stored-as-string
print_color() {
    case $1 in
    bred)
        color="${BRed}"
        ;;

    bgreen)
        color="${BGreen}"
        ;;

    byellow)
        color="${BYellow}"
        ;;

    bblue)
        color="${BBlue}"
        ;;

    *)
        color="${Color_Off}"
        ;;
    esac

    echo -e "${color}$2${Color_Off}"
}

read -rp "Enter bitwarden email: " BW_CLI_EMAIL
read -rsp "Enter bitwarden password: " BW_CLI_PASS
echo

print_color bgreen "Updating..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

print_color bgreen "Installing packages..."
sudo apt install wget unzip curl jq git gh -y

BW_CLI_ZIP_FILE_NAME="bw-cli.zip"

print_color bgreen "Installing bitwarden cli..."
wget -nv -O "${BW_CLI_ZIP_FILE_NAME}" "https://vault.bitwarden.com/download/?app=cli&platform=linux"
unzip "${BW_CLI_ZIP_FILE_NAME}"
sudo install bw /usr/local/bin/
rm -rf "${BW_CLI_ZIP_FILE_NAME}" bw

BW_NOTE_NAME="Linux Setup Script"

print_color bgreen "Logging into bitwarden cli..."
BW_SESSION=$(bw login "${BW_CLI_EMAIL}" "${BW_CLI_PASS}" | grep -oP '(?<=BW_SESSION=")[^"]+')

# outputs the following variables: GIT_USER_NAME, GIT_USER_EMAIL
eval "$(bw get item "${BW_NOTE_NAME}" --session "${BW_SESSION}" | jq -r '.fields[] | "declare \(.name)=\"\(.value)\""')"

# TODO: set up ssh keys

# TODO: check to make sure vars from bw are set and if not, prompt for them (or skip)

print_color bgreen "Configuring git..."
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
git config --global core.editor "code --wait"
git config --global init.defaultBranch main

# git aliases
git config --global alias.undo "reset --soft HEAD^"

# TODO: configure gh

print_color bgreen "Installing fnm..."
if [[ $(which fnm) == '' ]]; then
    curl -fsSL https://fnm.vercel.app/install | bash
    # TODO: add bash completion

    # shellcheck source=/dev/null
    source ~/.bashrc
else
    print_color byellow "\tAlready installed, upgrading instead..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi
fnm install --latest

print_color bgreen "Logging out of bitwarden cli..."
bw logout

print_color bgreen "Finished!"
