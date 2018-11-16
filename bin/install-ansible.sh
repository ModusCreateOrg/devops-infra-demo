#!/usr/bin/env bash
# Install Ansible

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

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
