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

check_every 2
