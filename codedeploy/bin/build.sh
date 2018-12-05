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

BUILD_NUMBER=${BUILD_NUMBER:-$(git rev-parse --short HEAD)}
echo "BUILD_NUMBER=$BUILD_NUMBER"
ARCHIVE="codedeploy-$BUILD_NUMBER.zip"

# Thanks https://stackoverflow.com/questions/33791069/quick-way-to-get-aws-account-number-from-the-cli-tools
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
BUCKET="codedeploy-$AWS_ACCOUNT_ID"

if [[ -d "$BUILD_DIR" ]]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"

SOURCES="$BASE_DIR/bin
$ANSIBLE_DIR
$APPLICTION_DIR
$SRC_DIR
$BASE_DIR/appspec.yml
$BASE_DIR/bin"
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

aws s3 cp "$ARCHIVE" "s3://$BUCKET/$ARCHIVE"
