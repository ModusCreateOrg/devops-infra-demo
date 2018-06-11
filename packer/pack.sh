#!/usr/bin/env bash

set -eou pipefail

set +e
# Technique for determining what subnet I live in on EC2 cribbed from:
# https://gist.github.com/samkeen/4255e1c8620be643d692
# Thanks to GitHub user samkeen
INTERFACE=$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/  --connect-timeout 1)
set -e
if [[ -n "$INTERFACE" ]]; then  # we are running on EC2
    echo "Running on EC2, get subnet IDs from instance data"
    PACKER_AWS_SUBNET_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/subnet-id)"
    PACKER_AWS_VPC_ID="$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/"$INTERFACE"/vpc-id)"
fi

docker run -i -t  \
    --env-file <(grep ^export ../env.sh | cut -c8-) \
    -e "PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID" \
    -e "PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID" \
    --mount type=bind,source="$(PWD)",target=/app \
    hashicorp/packer:light \
    validate app/machines/web-server.json
 docker run -i -t  \
    --env-file <(grep ^export ../env.sh | cut -c8-) \
    -e "PACKER_AWS_SUBNET_ID=$PACKER_AWS_SUBNET_ID" \
    -e "PACKER_AWS_VPC_ID=$PACKER_AWS_VPC_ID" \
    --mount type=bind,source="$(pwd)",target=/app \
    hashicorp/packer:light \
    build app/machines/web-server.json
