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

# Identity to decrypt gpg-Files:
username="Bogdan Irp"

abort() { printf "\e[0;31m\n   $*\n\e[0m"; exit 1; }

[[ ! $(which oathtool) ]] && abort "oathtool is not installed."

if [ ${1} ]; then
    if [[ ${1} == "-h" ]]; then
        echo "Usage: $0 [OPTION] <SERVICE>"
        echo " "
        echo "     <SERVICE>                 - show TOTP for <SERVICE>"
        echo "  -e <SERVICE>                 - encrypt ~/<SERVICE>.key"
        echo "  -n [SERVICE] [Security-Key]  - create new entry"

    elif [[ ${1} == "-e" ]]; then
        [[ ! ${2} ]] && abort "No service specified."
        [[ ! -f "${HOME}/.otpkeys/${2}.key" ]] && abort "No entry for ${2} available."
        gpg -e -r "$username" ~/.otpkeys/${2}.key
        echo "Source file has not been changed."

    elif [ -f "${HOME}/.otpkeys/${1}.key.gpg" ]; then
        oathtool -b --totp $(gpg -d ~/.otpkeys/${1}.key.gpg 2>/dev/null)

    elif [ -f "${HOME}/.otpkeys/${1}.key" ]; then
        oathtool -b --totp $(cat ~/.otpkeys/${1}.key)
        echo "(Keyfile is unencrypted)"

    else
        echo "No entry for ${1} available."
    fi
else
    n=0
    services=($(ls -1 ~/.otpkeys/*.{key,gpg} 2>/dev/null|grep -o '[^/]*$'|cut -d"." -f1|sort|uniq))
    for service in ${services[*]}; do
        n=$((n+1))
        echo "$n) $service"
    done
    read -p "Choice: " choice
    choice=$((choice-1))
    echo -e "\n${services[$choice]}"
    $0 ${services[$choice]}
fi
