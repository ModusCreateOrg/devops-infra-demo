#!/usr/bin/env bash

set -euo pipefail

# Credit to Stack Overflow questioner Jiarro and answerer Dave Dopson
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# shellcheck disable=SC1090
. "$DIR/common.sh"

cd "$DIR/.."

if is_ec2; then
    PACKER_AWS_SUBNET_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/subnet-id)"
    PACKER_AWS_VPC_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/vpc-id)"
fi

# Clean up the env file for use in packer
TMPFILE="$(mktemp)"
grep ^export env.sh | cut -c8- > "$TMPFILE"

# Only use TTY for Docker if we detect one, otherwise
# this will balk when run in Jenkins
# Thanks https://stackoverflow.com/a/48230089
USE_TTY=""
test -t 1 && USE_TTY="-t"

DOCKER_PACKER="docker run -i 
    ${USE_TTY}  
    --env-file $TMPFILE
    -e PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID 
    -e PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID 
    --mount type=bind,source=$(pwd),target=/app 
    hashicorp/packer:light"

$DOCKER_PACKER validate app/packer/machines/web-server.json
$DOCKER_PACKER build app/packer/machines/web-server.json

rm -f "$TMPFILE"
