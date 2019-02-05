#!/usr/bin/env bash
# Set the newrelic license key fron AWS credentials
#
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
export BASE_DIR

NEWRELIC_CONFIG_FILE="/etc/newrelic-infra.yml"
# Thanks Stack Overflow https://stackoverflow.com/a/9735663/424301
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EC2_REGION="$(sed 's/[a-z]$//' <<<"$EC2_AVAIL_ZONE")"

NEWRELIC_LICENSE_KEY=$(aws secretsmanager get-secret-value \
    --region="$EC2_REGION" \
    --secret-id newrelic_license \
    --output text \
    --query '[SecretString]')

cp -a "${NEWRELIC_CONFIG_FILE}" "${NEWRELIC_CONFIG_FILE}.orig"
sed "s/ZZZZ*ZZZZ/${NEWRELIC_LICENSE_KEY}/" "${NEWRELIC_CONFIG_FILE}.orig" > "${NEWRELIC_CONFIG_FILE}"
