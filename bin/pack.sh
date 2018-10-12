#!/usr/bin/env bash
# Run packer to create machine imaages
#
# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Enable for enhanced debugging
#set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."
export BASE_DIR

# shellcheck disable=SC1090
. "$DIR/common.sh"

DOCKER_PACKER=$(get_docker_packer)
$DOCKER_PACKER validate app/packer/machines/web-server.json
$DOCKER_PACKER build app/packer/machines/web-server.json
