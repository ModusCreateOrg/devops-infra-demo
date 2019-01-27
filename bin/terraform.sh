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

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."
BUILD_DIR="$BASE_DIR/build"
#shellcheck disable=SC1090
. "$DIR/common.sh"
#shellcheck disable=SC1090
. "$BASE_DIR/env.sh"
#shellcheck disable=SC1090
. "$DIR/common-terraform.sh"

DOCKER_TERRAFORM=$(get_docker_terraform)
DOCKER_LANDSCAPE=$(get_docker_landscape)

verb=${1:?You must specify a verb: plan, plan-destroy, apply, show, output}

# Inject Google application credentials into env file for docker
GOOGLE_APPLICATION_CREDENTIALS_OVERRIDE=${GOOGLE_APPLICATION_CREDENTIALS_OVERRIDE:-}
if [[ -n "$GOOGLE_APPLICATION_CREDENTIALS_OVERRIDE" ]]; then
    echo "Overriding Google Application Credentials"
    GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS_OVERRIDE"
fi

# Set up Google creds in build dir for docker terraform
mkdir -p "$BUILD_DIR"
cp "$GOOGLE_APPLICATION_CREDENTIALS" "$BUILD_DIR/google.json"
# Ugh. Jenkins was failing to extract the stash containing this file
# because google.json had a umask of 0400 (read only to user):
#     java.io.IOException: Failed to extract plan.tar.gz
# This is similar to the problem listed here: 
# https://issues.jenkins-ci.org/browse/JENKINS-33126
chmod u+w "$BUILD_DIR/google.json"
sed -i.bak '/GOOGLE_APPLICATION_CREDENTIALS/d' "$ENV_FILE"
#shellcheck disable=SC2086
GOOGLE_PROJECT_OVERRIDE=$(awk 'BEGIN { FS = "\"" } /project_id/{print $4}' <$GOOGLE_APPLICATION_CREDENTIALS)
cat <<EOF >>"$ENV_FILE"
GOOGLE_APPLICATION_CREDENTIALS=/app/build/google.json
GOOGLE_PROJECT=$GOOGLE_PROJECT_OVERRIDE
EOF

# http://redsymbol.net/articles/bash-exit-traps/
trap clean_root_owned_docker_files EXIT

function show() {
    local -i retcode
    #shellcheck disable=SC2086
    $DOCKER_TERRAFORM show
}

function output () {
    local -i retcode
    local extra
    #shellcheck disable=SC2086
    $DOCKER_TERRAFORM output "$@"
}

function plan() {
    local extra
    local output
    local -i retcode
    local targets
    extra=${1:-}
    output="$(mktemp)"
    targets=$(get_targets)

    set +e
    #shellcheck disable=SC2086
    $DOCKER_TERRAFORM plan \
        $extra \
        $targets \
        -lock=true \
        -input="$INPUT_ENABLED" \
        -var project_name="$PROJECT_NAME" \
        -var-file="/app/build/extra.tfvars" \
        -out="$TF_PLAN" \
        "$TF_DIR" \
        > "$output"
    retcode="$?"
    set -e
    if [[ "$retcode" -eq 0 ]]; then
        $DOCKER_LANDSCAPE - < "$output"
    else
        cat "$output"
    fi
    rm -f "$output"
    return "$retcode"
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
show)
  Message="Executing terraform show."
  ;;
output)
  Message="Executing terraform output."
  ;;
*)
  echo 'Unrecognized verb "'"$verb"'" specified. Use plan, plan-destroy, apply, or show'
  exit 1
  ;;
esac
shift
echo "$Message" 1>&2
init_terraform 1>&2
"$verb" "$@"

