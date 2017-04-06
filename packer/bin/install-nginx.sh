#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

set +e
dpkg-query -W nginx
if [[ $? -ne 0 ]]; then
	sudo apt-get update && sudo apt-get install -qy nginx
fi
set -e

mkdir -p /usr/share/nginx/html
