#!/usr/bin/env bash
# Install openscap and run a security scan

set -euo pipefail

sudo yum -q install -y openscap-scanner scap-security-guide

mkdir -p build
cd build
# This will have a non-zero exit if any of the scans fail, so do not fail immediately on that
set +e
sudo oscap xccdf eval --profile C2S --results scan-xccdf-results.xml /usr/share/xml/scap/ssg/content/ssg-centos7-xccdf.xml
set -e

oscap xccdf generate report scan-xccdf-results.xml > scan-xccdf-results.html
