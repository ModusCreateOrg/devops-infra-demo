#!/usr/bin/env bash
#
# AfterInstall.sh
#
# AWS CodeDeploy After Install hook script

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Credit to http://stackoverflow.com/a/246128/424301
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$DIR/../.."
ANSIBLE_DIR="$BASE_DIR/ansible"

# Invoke Ansible for final set up
ansible-playbook -l localhost "$ANSIBLE_DIR/app-AfterInstall.yml"

# Configure New Relic
# TODO: move into Ansible playbook app-AfterInstall.yml
NEWRELIC_CONFIG_DIR=/app
VENV_DIR=/app/venv
# Thanks Stack Overflow https://stackoverflow.com/a/9735663/424301
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
EC2_REGION="$(sed 's/[a-z]$//' <<<"$EC2_AVAIL_ZONE")"

NEWRELIC_LICENSE_KEY=$(aws secretsmanager get-secret-value \
    --region="$EC2_REGION" \
    --secret-id newrelic_license \
    --output text \
    --query '[SecretString]')
set +u
#shellcheck disable=SC1090
source ${VENV_DIR}/bin/activate
set -u
newrelic-admin generate-config "${NEWRELIC_LICENSE_KEY}" "${NEWRELIC_CONFIG_DIR}/newrelic.ini.orig"
sed 's/^app_name =.*$/app_name = Spin/' "${NEWRELIC_CONFIG_DIR}/newrelic.ini.orig" > "${NEWRELIC_CONFIG_DIR}/newrelic.ini"
