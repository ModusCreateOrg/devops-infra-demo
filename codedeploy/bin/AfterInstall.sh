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
BASE_DIR="$DIR/.."
ANSIBLE_DIR="$BASE_DIR/ansible"

# Invoke Ansible for final set up
ansible-playbook -l localhost "$ANSIBLE_DIR/app-AfterInstall.yml"

# Configure New Relic
NEWRELIC_CONFIG_DIR=/app
VENV_DIR=/app/venv
NEWRELIC_LICENSE_KEY=$(aws secretsmanager get-secret-value --secret-id newrelic_license --output text --query '[SecretString]')
${VENV_DIR}/bin/activate
newrelic-admin generate-config ${NEWRELIC_LICENSE_KEY} ${NEWRELIC_CONFIG_DIR}/newrelic.ini.orig
sed 's/^app_name =.*$/app_name = Spin/' ${NEWRELIC_CONFIG_DIR}/newrelic.ini.orig > ${NEWRELIC_CONFIG_DIR}/newrelic.ini
#rm -f ${NEWRELIC_CONFIG_DIR}/newrelic.ini.orig