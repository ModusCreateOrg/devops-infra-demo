#!/usr/bin/env bash
#
# ValidateService.sh
#
# AWS CodeDeploy Validate Service hook script

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

GAUNTLT_RESULTS=/app/build/gauntlt-results.html
# TODO: save this to S3 instead
GAUNTLT_RESULTS_SAVE="/home/centos/$DEPLOYMENT_ID-gauntlt-results.html"

check_every() {
    local delay=${1:-}
    local host="http://localhost/"
    # shellcheck disable=SC2048
    while ! curl -s -o /dev/null $host
    do
        sleep "$delay"
        echo "Sleeping $delay, $host was not reachable"
    done
}

echo "Checking web server availability"
check_every 2

echo "Scanning with openscap and gauntlt"
mkdir -p /app/build /app/ansible/tmp
cat < /dev/null > "$GAUNTLT_RESULTS"
chown -R centos:centos "$GAUNTLT_RESULTS" /app/build /app/ansible/tmp
chmod 755 "$GAUNTLT_RESULTS" /app/build /app/ansible/tmp

set +e
sudo -u centos HOME=/home/centos /app/bin/ansible.sh scan-openscap.yml scan-gauntlt.yml
RETCODE=$?
set -e
cp "$GAUNTLT_RESULTS" "$GAUNTLT_RESULTS_SAVE"
rm -rf /app/ansible/tmp /app/build
exit "$RETCODE"
