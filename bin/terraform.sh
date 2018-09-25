#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Enable for enhanced debugging
#set -vx

# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

verb=${1:?You must specify a verb: plan, plan-destroy, apply}
echo "TODO: invoke terraform"


DOCKER_TERRAFORM="docker run -i
    ${USE_TTY}
    --env-file $TMPFILE
    -e PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID
    -e PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID
    --mount type=bind,source=$(pwd),target=/app
    hashicorp/packer:light"

function plan() {
}

function destroy() {
}

function apply() {
}

case "$verb" in
plan)
  Message="plan."
  ;;
plan-destroy)
  Message="destroy."
  ;;
apply)
  Message="apply."
  ;;
*)
  echo "Unrecognized verb $verb specified. Use plan, plan-destroy, or apply"
  exit 1
  ;;
esac

echo "$Message"

