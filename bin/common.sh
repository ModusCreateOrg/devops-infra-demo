#!/usr/bin/env bash
# common.sh

# Only use TTY for Docker if we detect one, otherwise
# this will balk when run in Jenkins
# Thanks https://stackoverflow.com/a/48230089
declare USE_TTY
test -t 1 && USE_TTY="-t" || USE_TTY=""

declare INPUT_ENABLED
test -t 1 && INPUT_ENABLED="true" || INPUT_ENABLED="false"

export INPUT_ENABLED USE_TTY

# https://gist.github.com/samkeen/4255e1c8620be643d692
# Thanks to GitHub user samkeen
function is_ec2() {
    set +e
    INTERFACE=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/  --connect-timeout 1)
    set -e
    if [[ -n "$INTERFACE" ]]; then  # we are running on EC2
        return 0
    fi
    return 1
}

function get_env_tmpfile() {
# Clean up the env file for use in packer & terraform
    local TMPFILE
    TMPFILE="$(mktemp)"
    grep ^export "$DIR/../env.sh" | cut -c8- > "$TMPFILE"
    echo "$TMPFILE"
}

function get_aws_account_id() {
    aws sts get-caller-identity \
        --query Arn \
        --output text \
        | cut -d: -f5
}

function clean_root_owned_docker_files {
    # Fix file permissions on Jenkins / Linux as
    # Docker makes a bunch of root-owned files as it works
    local TF_DIR=/app
    local BASE_DIR
    BASE_DIR="$(pwd)"
    if is_ec2; then
        docker run -i \
            --mount type=bind,source="${BASE_DIR}",target="${TF_DIR}" \
            -w "${TF_DIR}" \
            --entrypoint /bin/sh \
            busybox \
            <<< "chown -R $(id -u):$(id -g) ${TF_DIR}"
    fi
}

function get_docker_packer {
    # This is going to leak a new tempfile every time
    # it is run, maybe we should chain the exit traps to
    # avoid this. https://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal
    local TMPFILE
    TMPFILE=$(get_env_tmpfile)
    if is_ec2; then
        PACKER_AWS_SUBNET_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/subnet-id)"
        PACKER_AWS_VPC_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/vpc-id)"
    fi

    echo "docker run -i
        ${USE_TTY}
        --env-file $TMPFILE
        -e PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID
        -e PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID
        --mount type=bind,source=${BASE_DIR},target=/app
        hashicorp/packer:light"
}

function get_docker_landscape() {
    echo "docker run -i --rm alpine/landscape"
}

function get_docker_shellcheck() {
    # See https://hub.docker.com/r/nlknguyen/alpine-shellcheck/
    # and https://github.com/koalaman/shellcheck/issues/727
    echo "docker run --rm -i ${USE_TTY} -v $(pwd):/mnt koalaman/shellcheck"
}

function ensure_root () {
    # Thanks Unix Stack Exchange https://unix.stackexchange.com/a/389407
    if ((EUID != 0)); then
        echo >&2 "Error: script not running as root or with sudo! Exiting..."
        exit 1
    fi
}

function ensure_not_root () {
    # Thanks Unix Stack Exchange https://unix.stackexchange.com/a/389407
    if ((EUID == 0)); then
        echo >&2 "Error: do not run script as root or with sudo! Exiting..."
        exit 1
    fi
}


function quick_yum_install() {
    declare package
    package=${1?"You must specify a package to install"}
    local sudo_maybe=''
    ((EUID != 0)) && sudo_maybe='sudo'
    if ! rpm -q  "$package" > /dev/null; then
        $sudo_maybe yum -y -q install "$package"
    else
        echo "$package already installed, skipping" >&2
    fi
}
