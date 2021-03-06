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

# shellcheck disable=SC1090
. "$DIR/common.sh"
#shellcheck disable=SC1090
. "$BASE_DIR/env.sh"

BUILD_NUMBER=${BUILD_NUMBER:-0}
BUCKET="codedeploy-$(get_aws_account_id)"
PARAM=${1:-}
BRANCH_PREFIX=${2:-master}
APP_NAME=${3:-tf-infra-demo-app}
DEPLOYMENT_GROUP_NAME=${4:-dev}

GIT_REV="$(git rev-parse --short HEAD)"
ARCHIVE="codedeploy-$BRANCH_PREFIX-$BUILD_NUMBER-$GIT_REV.zip"
# Thanks https://stackoverflow.com/questions/33791069/quick-way-to-get-aws-account-number-from-the-cli-tools
S3_URL="s3://$BUCKET/$ARCHIVE"

# Thanks https://stackoverflow.com/questions/33791069/quick-way-to-get-aws-account-number-from-the-cli-tools
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
BUCKET="codedeploy-$AWS_ACCOUNT_ID"

case $PARAM in
    s3[:]//[a-z0-9]*)
        S3_URL="$PARAM"
        ARCHIVE=$(cut -d/ -f 3- <<<"$S3_URL")
        BUCKET=$(cut -d/ -f 2- <<<"$S3_URL")
        ;;
    current)
        echo "Using current CodeDeploy build: $S3_URL"
        ;;
    *)
        echo "ERROR: Unknown format for $PARAM, exiting"
        exit 1
        ;;
esac


S3_SHORTHAND="bundleType=zip,bucket=$BUCKET,key=$ARCHIVE"

echo "BRANCH_PREFIX=$BRANCH_PREFIX"
echo "BUILD_NUMBER=$BUILD_NUMBER"
echo "ARCHIVE=$ARCHIVE"
echo "S3_URL=$S3_URL"
echo "S3_SHORTHAND=$S3_SHORTHAND"


DEPLOYMENT_ID=$(aws deploy create-deployment \
          --region "$AWS_DEFAULT_REGION" \
          --output text \
          --query '[deploymentId]' \
          --application-name "$APP_NAME" \
          --deployment-group-name "$DEPLOYMENT_GROUP_NAME" \
          --description "deployment initiated by deploy-codedeploy.sh" \
          --no-ignore-application-stop-failures \
          --s3-location "$S3_SHORTHAND")
echo "CodeDeploy: deployment started $DEPLOYMENT_ID"
echo "CodeDeploy: see https://console.aws.amazon.com/codesuite/codedeploy/deployments/$DEPLOYMENT_ID"
echo "CodeDeploy: waiting for deployment $DEPLOYMENT_ID to complete..."
aws deploy wait deployment-successful --deployment-id "$DEPLOYMENT_ID"
