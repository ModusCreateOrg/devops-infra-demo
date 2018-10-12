#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."
BUILD_DIR="$BASE_DIR/build"
export BUILD_DIR

# shellcheck disable=SC1090
. "$DIR/common.sh"


TF_VERSION=0.11.7
export TF_VERSION
# TF_DIR is from the perspective of the Terraform docker container
TF_DIR="/app/terraform"

TF_PLAN="$TF_DIR/tf.plan"
export TF_PLAN
ENV_FILE=$(get_env_tmpfile)
VAR_FILE="$(get_var_tmpfile "${Extra_Variables:-}")"
export VAR_FILE


export ENV_FILE

DOCKER_PACKER=$(get_docker_packer "$BASE_DIR")
echo "Linting packer files"
$DOCKER_PACKER validate app/packer/machines/web-server.json

# Ensure that `terraform fmt` comes up clean
echo "Linting terraform files for correctness"
DOCKER_TERRAFORM=$(get_docker_terraform)
$DOCKER_TERRAFORM validate
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
