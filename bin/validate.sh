#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."

# shellcheck disable=SC1090
. "$DIR/common.sh"

DOCKER_PACKER=$(get_docker_packer "$BASE_DIR")
$DOCKER_PACKER validate app/packer/machines/web-server.json

rm -f "$TMPFILE"
