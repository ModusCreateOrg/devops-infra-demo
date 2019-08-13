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

ensure_not_root

RUBY_VERSION=2.6.3
export RUBY_VERSION
RVM_SH="$HOME/.rvm/scripts/rvm"

PACKAGES='nmap
ruby-devel
autoconf
automake
bison
gcc-c++
libffi-devel
libtool
patch
readline-devel
sqlite-devel
zlib-devel
glibc-headers
glibc-devel
openssl-devel
requirements_centos_libs_install
patch
autoconf
automake
bison
gcc-c++
libffi-devel
libtool
patch
readline-devel
sqlite-devel
zlib-devel
glibc-headers
glibc-devel
openssl-devel'

#shellcheck disable=SC2086
sudo yum -q install -y $PACKAGES

if [[ ! -f "$RVM_SH" ]]; then
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
    curl -L get.rvm.io | bash -s stable
    # rvm hates the bash options -eu
    set +eu
    #shellcheck disable=SC1091,SC1090
    . "$RVM_SH"
    rvm reload
    rvm requirements run
    set -eu
else
    echo "rvm already installed" >&2
fi

#shellcheck disable=SC1090
. "$DIR/activate-rvm.sh"

if ! (gem list gauntlt | grep gauntlt > /dev/null); then
    echo 'gem: --no-rdoc --no-ri' > ~/.gemrc
    gem install gauntlt syntax
fi
