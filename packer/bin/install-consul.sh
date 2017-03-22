#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

CONSUL_VERSION=0.7.5

function exists()
{
  local program=$1
  set +e
  local retval=$(hash ${program} 2>/dev/null)
  set -e
  return $retval
}

if [[ ! $(exists consul) ]]; then
  sleep 90
  sudo apt-get update && sudo apt-get install -qy curl unzip
  curl -sLO https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
  unzip consul_${CONSUL_VERSION}_linux_amd64.zip
  sudo mv consul /usr/local/bin/
  rm consul_${CONSUL_VERSION}_linux_amd64.zip
fi

sudo mkdir -p /opt/consul
sudo mkdir -p /etc/consul.d
