#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo yum -y -q install epel-release
sudo yum -y -q install ansible
ansible-galaxy install -r /app/ansible/requirements.yml
