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
ANSIBLE_DIR="$BASE_DIR/../ansible"
APPLICTION_DIR="$BASE_DIR/../application"
SRC_DIR="$BASE_DIR/../src"
VENV_DIR="$BASE_DIR/../venv"
DOCKER_DIR="$BASE_DIR/.."

GIT_REV="$(git rev-parse --short HEAD)"
BUILD_NUMBER=${BUILD_NUMBER:-0}
ARCHIVE="codedeploy-$BUILD_NUMBER-$GIT_REV.zip"
CONTAINERNAME=infra-demo

echo "GIT_REV=$GIT_REV"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "ARCHIVE=$ARCHIVE"

# Thanks https://stackoverflow.com/questions/33791069/quick-way-to-get-aws-account-number-from-the-cli-tools
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
BUCKET="codedeploy-$AWS_ACCOUNT_ID"

if [[ -d "$BUILD_DIR" ]]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

echo Build docker container $CONTAINERNAME
docker build -f=Dockerfile -t "$CONTAINERNAME" "$DOCKER_DIR"

echo Create python virtual environment
docker run --rm -v "$DOCKER_DIR:/src" "$CONTAINERNAME" /bin/bash -c \
    "mkdir -p /src/venv ; \
    cp -fa /app/venv/* /src/venv"

SOURCES="$BASE_DIR/bin
$ANSIBLE_DIR
$APPLICTION_DIR
$SRC_DIR
$BASE_DIR/appspec.yml
$BASE_DIR/bin
$VENV_DIR"
for src in $SOURCES; do
    cp -a "$src" "$BUILD_DIR"
done

cd "$BUILD_DIR"
zip -r "$ARCHIVE" \
    appspec.yml \
    bin \
    ansible \
    application \
    src \
    venv
cd -

echo Remove docker generated files
docker run --rm -v "$DOCKER_DIR:/src" "$CONTAINERNAME" /bin/bash -c \
    "rm -rf /src/venv"

aws s3 cp "$ARCHIVE" "s3://$BUCKET/$ARCHIVE"
