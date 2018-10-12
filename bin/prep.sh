#!/usr/bin/env bash
# Prepare a clean environment

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

# shellcheck disable=SC1090
. "$DIR/common.sh"

cd "$BASE_DIR"
clean_root_owned_docker_files
git clean -fdx
cp env.sh.sample env.sh
rm -rf build
mkdir -p build
