#!/bin/bash
#
# File: otp.sh
#
# Creates One Time Passwords from keyfiles
#
# Usage: otp.sh <SERVICE>
#
# Creation Date: 20.04.2020
#
# Bogdan Irp (bogdan@meisernet.edu)
#
# Each service must have a keyfile in directory ~/.otpkeys
# with the name <SERVICE>.key, or <SERVICE>.key.gpg for
# encrypted files. These files contain the secret key which
# is used to calculate the One Time Password.
#
# Encrypt keyfile:
# gpg -e -r "Bogdan Irp" <SERVICE>.key

# Identity for encrypting with GPG
username="Bogdan Irp"

abort() { printf "\e[0;31m\n   $*\n\e[0m"; exit 1; }
confirm() { read -sn 1 -p "$* [Y/N] "; [[ ${REPLY:0:1} = [JjYy] ]]; }

[[ ! $(which oathtool) ]] && abort "oathtool is not installed."

# Ask for creation of directory if not exists
if [[ ! -d ~/.otpkeys ]]; then
    echo -n "~/.otpkeys does not exist. "
    if confirm "Create?"; then
        mkdir ~/.otpkeys
        exit 0
    else
        abort "\nAbort."
    fi
fi

if [ ${1} ]; then
    if [[ ${1} == "-h" ]]; then
        echo "Usage: $0 [OPTION] <SERVICE>"
        echo " "
        echo "     <SERVICE>                 - show TOTP for <SERVICE>"
        echo "  -e <SERVICE>                 - encrypt ~/<SERVICE>.key"
        echo "  -d <SERVICE>                 - decrypt ~/<SERVICE>.key"
        echo "  -n [SERVICE] [Security Key]  - create new entry"

    # encrypt existing keyfile
    elif [[ ${1} == "-e" ]]; then
        [[ ! ${2} ]] && abort "No service specified."
        [[ ! -f "${HOME}/.otpkeys/${2}.key" ]] && abort "No unencrypted entry for ${2} available."
        gpg -e -r "$username" ~/.otpkeys/${2}.key && rm -f ~/.otpkeys/${2}.key
        echo "(Encrypted: ${2}.key -> ${2}.key.gpg)"

    # show decrypted secret
    elif [[ ${1} == "-d" ]]; then
        [[ ! ${2} ]] && abort "No service specified."
        [[ ! -f "${HOME}/.otpkeys/${2}.key.gpg" ]] && abort "No encrypted entry for ${2} available."
        gpg -d ~/.otpkeys/${2}.key.gpg 2>/dev/null
        echo "(Encrypted file is unchanged)"

    # create new token
    elif [[ ${1} == "-n" ]]; then
        [[ ! ${3} ]] && abort "otpcli.sh -n [SERVICE] [Security-Key]"
        [[ -f ~/.otpkeys/${2}.key ]] && abort "Entry for ${2} already exists."
        echo ${3} > ~/.otpkeys/${2}.key

    # check for encrypted keyfile...
    elif [ -f "${HOME}/.otpkeys/${1}.key.gpg" ]; then
        oathtool -b --totp $(gpg -d ~/.otpkeys/${1}.key.gpg 2>/dev/null)

    # ... or look for clear text instead
    elif [ -f "${HOME}/.otpkeys/${1}.key" ]; then
        oathtool -b --totp $(cat ~/.otpkeys/${1}.key)
        echo "(Keyfile is unencrypted)"

    else
        abort "No entry for ${1} available."
    fi
else
    n=0
    services=($(ls -1 ~/.otpkeys/*.{key,gpg} 2>/dev/null|grep -o '[^/]*$'|cut -d"." -f1|sort|uniq))
    for service in ${services[*]}; do
        n=$((n+1))
        echo "$n) $service"
    done

    # no existing keyfile 
    [[ $n == 0 ]] && abort "Create a token with otp.sh -n [SERVICE] [Security Key]"

    read -p "Choice: " choice
    choice=$((choice-1))
    echo -e "\n${services[$choice]}"
    $0 ${services[$choice]}
fi
