#!/usr/bin/env bash
# Run ansible 
#
# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck disable=SC1090
. "$DIR/common.sh"
# shellcheck disable=SC1090
. "$DIR/activate-rvm.sh"

ensure_not_root

cd "$DIR/../ansible"
ansible-playbook -l localhost $@
/app/ansible/bakery.yml /app/ansible/scan-openscap.yml /app/ansible/scan-gauntlt.yml
