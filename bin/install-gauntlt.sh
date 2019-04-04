#!/usr/bin/env bash
# Install gauntlt using rvm

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#shellcheck disable=SC1090
. "$DIR/common.sh"

function quick_yum_install() {
    declare package
    package=${1?"You must specify a package to install"}
    if ! rpm -q  "$package" > /dev/null; then
        sudo yum -y -q install "$package"
    else
        echo "$package already installed, skipping"
    fi
}

quick_yum_install ruby-devel
quick_yum_install nmap

if [[ ! -f /etc/profile.d/rvm.sh ]]; then
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
    curl -L get.rvm.io | bash -s stable
    # rvm hates the bash options -eu
    set +eu
    #shellcheck disable=SC1091
    source /etc/profile.d/rvm.sh
    rvm reload
    rvm requirements run
else
    echo "rvm already installed"
fi
# rvm hates the bash options -eu
set +eu
#shellcheck disable=SC1091
source /etc/profile.d/rvm.sh
rvm reload
rvm install 2.6.0
rvm alias create default ruby-2.6.0
rvm list
rvm use 2.6 --default
set -eu
if is_ec2; then
    usermod -a -G rvm centos
else
    usermod -a -G rvm vagrant
fi
ruby --version

if ! (gem list gauntlt | grep gauntlt > /dev/null); then
    echo 'gem: --no-rdoc --no-ri' > ~/.gemrc
    gem install gauntlt
fi
