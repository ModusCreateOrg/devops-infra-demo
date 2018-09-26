#!/usr/bin/env bash
#
# terraform.sh
#
# Wrapper script for running Terraform through Docker
#
# Useful when running in Jenkins CI or other contexts where you have Docker
# available.

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
#IFS=$'\n\t'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."
PROJECT_NAME="$( cd "$BASE_DIR" && basename "$(pwd)")"
#shellcheck disable=SC1090
. "$DIR/common.sh"
#shellcheck disable=SC1090
. "$BASE_DIR/env.sh"

# Enable for enhanced debugging
set -vx

# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

verb=${1:?You must specify a verb: plan, plan-destroy, apply}

TF_VERSION=0.11.7
# TF_DIR is from the perspective of the Terraform docker container
TF_DIR="/app"

TF_PLAN="$TF_DIR/tf.plan"
AWS_ACCOUNT_ID=$(get_aws_account_id)

DOCKER_TERRAFORM="docker run -i
    ${USE_TTY}
    --env-file $(get_env_tmpfile)
    --mount type=bind,source=${BASE_DIR}/terraform,target=${TF_DIR}
    --mount type=bind,source=${HOME}/.aws,target=/root/.aws
    --mount type=bind,source=${HOME}/.ssh,target=/root/.ssh
    -w ${TF_DIR}
    hashicorp/terraform:${TF_VERSION}"

# http://redsymbol.net/articles/bash-exit-traps/
function finish {
    # Fix file permissions on Jenkins / Linux as
    # Docker makes a bunch of root-owned files as it works
    if is_ec2; then
        docker run -i \
            --mount type=bind,source="${BASE_DIR}"/terraform,target="${TF_DIR}" \
            -w "${TF_DIR}" \
            --entrypoint /bin/sh \
            hashicorp/terraform:"${TF_VERSION}" \
            <<< "chown -R $(id -u):$(id -g) ${TF_DIR}"
    fi
}
trap finish EXIT

function plan() {
    local extra
    extra=${1:-}
    #shellcheck disable=SC2086
    $DOCKER_TERRAFORM plan \
        $extra \
        -lock=true \
        -input="$INPUT_ENABLED" \
        -var project_name="$PROJECT_NAME" \
        -out="$TF_PLAN" \
        "$TF_DIR"
}

function plan-destroy() {
   cat <<EOF

*******************************************************
************                             **************
************  -----=== WARNING ===------ **************
************  Planning Terraform Destroy ************** 
************                             ************** 
*******************************************************

EOF
    plan "-destroy"
}

function apply() {
    $DOCKER_TERRAFORM apply \
        -lock=true \
        "$TF_PLAN"
}

function init() {
    #shellcheck disable=SC2086
    $DOCKER_TERRAFORM init \
        -input="$INPUT_ENABLED" \
        -backend-config bucket=tf-state.${PROJECT_NAME}.${AWS_DEFAULT_REGION}.${AWS_ACCOUNT_ID} \
        -backend-config dynamodb_table=TerraformStatelock-${PROJECT_NAME}
    # Generate an SSH keypair if none exists yet
    if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
        #shellcheck disable=SC2174
        mkdir -p -m 0700 ~/.ssh
        ssh-keygen -t rsa -b 2048 -P '' -f ~/.ssh/id_rsa
    fi
}

case "$verb" in
plan)
  Message="Executing terraform plan."
  ;;
plan-destroy)
  Message="Executing terraform plan, with destroy."
  ;;
apply)
  Message="Executing terraform apply."
  ;;
*)
  echo 'Unrecognized verb "'"$verb"'" specified. Use plan, plan-destroy, or apply'
  exit 1
  ;;
esac

echo "$Message"
init
"$verb"

