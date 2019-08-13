#!/usr/bin/env bash
# Install openscap and run a security scan

set -euo pipefail

# Set DEBUG to true for enhanced debugging: run prefixed with "DEBUG=true"
${DEBUG:-false} && set -vx
# Credit to https://stackoverflow.com/a/17805088
# and http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

sudo yum -q install -y openscap-scanner scap-security-guide

mkdir -p build
cd build
# This will have a non-zero exit if any of the scans fail, so do not fail immediately on that
set +e
sudo oscap xccdf eval --profile C2S --results scan-xccdf-results.xml --fetch-remote-resources /usr/share/xml/scap/ssg/content/ssg-centos7-xccdf.xml
set -e

oscap xccdf generate report scan-xccdf-results.xml > scan-xccdf-results.html
