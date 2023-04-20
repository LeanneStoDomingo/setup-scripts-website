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

print_color bgreen "Updating..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

print_color bgreen "Installing packages..."
sudo apt install wget unzip curl git gh -y

BW_CLI_ZIP_FILE_NAME="bw-cli.zip"

print_color bgreen "Installing bitwarden cli..."
wget -nv -O "${BW_CLI_ZIP_FILE_NAME}" "https://vault.bitwarden.com/download/?app=cli&platform=linux"
unzip "${BW_CLI_ZIP_FILE_NAME}"
sudo install bw /usr/local/bin/
rm -rf "${BW_CLI_ZIP_FILE_NAME}" bw

# TODO: log in to bitwarden cli

print_color bgreen "Configuring git..."
# TODO: finish git configuration
# git config --global user.name ""
# git config --global user.email ""
git config --global core.editor "code --wait"
git config --global init.defaultBranch main

# git aliases
git config --global alias.undo "reset --soft HEAD^"

# TODO: configure gh

print_color bgreen "Installing fnm..."
if [[ $(which fnm) == '' ]]; then
    curl -fsSL https://fnm.vercel.app/install | bash
    # TODO: add bash completion
    source ~/.bashrc
else
    print_color byellow "\tAlready installed, upgrading instead..."
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi
fnm install --latest

print_color bgreen "Finished!"
