#!/usr/bin/env bash

docker run -t -v "$(pwd):/repo" justb4/jmeter -n -t /repo/jmeter/api-spin.jmx "$@"
