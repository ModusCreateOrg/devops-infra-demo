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
ANSIBLE_DIR="$BASE_DIR/ansible"
APPLICTION_DIR="$BASE_DIR/application"
SRC_DIR="$BASE_DIR/src"
GAUNTLT_DIR="$BASE_DIR/gauntlt"

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/.."

# shellcheck disable=SC1090
. "$DIR/common.sh"
#shellcheck disable=SC1090
. "$BASE_DIR/env.sh"


GIT_REV="$(git rev-parse --short HEAD)"
BUILD_NUMBER=${BUILD_NUMBER:-0}
BRANCH_PREFIX=${1:-master}
ARCHIVE="codedeploy-$BRANCH_PREFIX-$BUILD_NUMBER-$GIT_REV.zip"
CONTAINERNAME=infra-demo
# Thanks https://stackoverflow.com/questions/33791069/quick-way-to-get-aws-account-number-from-the-cli-tools
AWS_ACCOUNT_ID=$(get_aws_account_id)
BUCKET="codedeploy-$AWS_ACCOUNT_ID"
S3_URL="s3://$BUCKET/$ARCHIVE"

echo "GIT_REV=$GIT_REV"
echo "BRANCH_PREFIX=$BRANCH_PREFIX"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "ARCHIVE=$ARCHIVE"
echo "S3_URL=$S3_URL"


if [[ -d "$BUILD_DIR" ]]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR/socket"

echo Build docker container $CONTAINERNAME
docker build -f=Dockerfile -t "$CONTAINERNAME" "$BASE_DIR"

echo Create python virtual environment
docker run \
    --rm \
    -v "$BASE_DIR:/src" \
    "$CONTAINERNAME" \
    /bin/bash -c \
        "mkdir -p /src/build/venv ; \
        cp -fa /app/venv/* /src/build/venv"

SOURCES="$BASE_DIR/bin
$ANSIBLE_DIR
$APPLICTION_DIR
$SRC_DIR
$GAUNTLT_DIR
$BASE_DIR/codedeploy/appspec.yml"
for src in $SOURCES; do
    cp -a "$src" "$BUILD_DIR"
done

(
    cd "$BUILD_DIR"
    zip -q -r "$ARCHIVE" \
        appspec.yml \
        bin \
        ansible \
        application \
        src \
        venv \
        socket
)

echo Remove docker generated files
docker run --rm -v "$BASE_DIR:/src" "$CONTAINERNAME" /bin/bash -c \
    "rm -rf /src/venv"

cd "$BUILD_DIR"
aws s3 cp "$ARCHIVE" "$S3_URL" --quiet
echo "CodeDeploy archive uploaded OK: $S3_URL"
aws s3 ls "$S3_URL"
