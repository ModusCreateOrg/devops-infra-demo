#!/usr/bin/env bash

# Set bash unofficial strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo yum -y -q install epel-release
sudo yum -y -q install ansible
ansible-galaxy install -r /app/ansible/requirements.yml
# Thanks https://www.tricksofthetrades.net/2017/10/02/ansible-local-playbooks/
#    and https://ubuntuforums.org/showthread.php?t=1294351
cat <<EOF | sudo tee  /etc/ansible/hosts
[local]
localhost ansible_connection=local
EOF
