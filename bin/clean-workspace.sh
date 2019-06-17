#!/usr/bin/env bash
# clean workspace
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
BASE_DIR="$DIR/.."
BUILD_DIR="$BASE_DIR/build"
export BASE_DIR

# shellcheck disable=SC1090
. "$DIR/common.sh"

cp "$BASE_DIR/env.sh.sample" "$BASE_DIR/env.sh"
clean_root_owned_docker_files
rm -rf "$BUILD_DIR"
git clean -fdx
mkdir "$BUILD_DIR"
