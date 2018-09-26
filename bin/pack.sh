#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASEDIR="$DIR/.."

# shellcheck disable=SC1090
. "$DIR/common.sh"

cd "$BASEDIR"

if is_ec2; then
    PACKER_AWS_SUBNET_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/subnet-id)"
    PACKER_AWS_VPC_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/vpc-id)"
fi

DOCKER_PACKER="docker run -i 
    ${USE_TTY}  
    --env-file $(get_env_tmpfile)
    -e PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID 
    -e PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID 
    --mount type=bind,source=${BASEDIR},target=/app 
    hashicorp/packer:light"

$DOCKER_PACKER validate app/packer/machines/web-server.json
$DOCKER_PACKER build app/packer/machines/web-server.json

rm -f "$TMPFILE"
