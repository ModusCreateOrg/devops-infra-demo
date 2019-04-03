#!/usr/bin/env bash
# Install rvm
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

quick_yum_install ruby-devel
quick_yum_install nmap

if [[ ! -f /etc/profile.d/rvm.sh ]]; then
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
    curl -L get.rvm.io | bash -s stable
    #shellcheck disable=SC1091
    source /etc/profile.d/rvm.sh
    rvm reload
    rvm requirements run
    rvm install 2.6.0
fi
rvm alias create default ruby-2.6.0
rvm list
rvm use 2.6 --default
ruby --version

gem list gauntlt || gem install gauntlt
