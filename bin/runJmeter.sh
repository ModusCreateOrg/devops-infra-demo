#!/usr/bin/env bash

docker run -t -v "$(pwd):/repo" justb4/jmeter -n -t /repo/devops-infra-demo-api-spin.jmx -l /repo/results.txt
