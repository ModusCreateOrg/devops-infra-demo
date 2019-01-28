#!/usr/bin/env bash

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
export BUILD_DIR

# shellcheck disable=SC1090
. "$DIR/common.sh"
# shellcheck disable=SC1090
. "$BASE_DIR/env.sh"
# shellcheck disable=SC1090
. "$DIR/common-terraform.sh"

DOCKER_PACKER=$(get_docker_packer "$BASE_DIR")
echo "Linting packer files"
$DOCKER_PACKER validate app/packer/machines/web-server.json

# Ensure that `terraform fmt` comes up clean
echo "Linting terraform files for correctness"
DOCKER_TERRAFORM=$(get_docker_terraform)
init_terraform
$DOCKER_TERRAFORM validate \
    -var 'newrelic_license_key=ZZZZ'
echo "Linting terraform files for formatting"
fmt=$($DOCKER_TERRAFORM fmt)
if [[ -n "$fmt" ]]; then
    echo 'ERROR: these files are not formatted correctly. Run "terraform fmt"'
    echo "$fmt"
    git diff
    exit 1
fi

echo "Linting shell scripts"
DOCKER_SHELLCHECK=$(get_docker_shellcheck)
# shellcheck disable=SC2046
$DOCKER_SHELLCHECK $(find . -name '*.sh') env.sh.sample
