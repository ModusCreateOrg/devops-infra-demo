#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Enable for enhanced debugging
#set -vx

function quick_yum_install() {
    declare package
    package=${1?"You must specify a package to install"}
    if ! rpm -q  "$package" > /dev/null; then
        sudo yum -y -q install "$package"
    fi
}
quick_yum_install epel-release
quick_yum_install ansible
ansible-galaxy install -r /app/ansible/requirements.yml
