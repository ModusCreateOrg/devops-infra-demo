#!/usr/bin/env bash
# Activate rvm
# Source this to activate RVM

# CodeDeploy has no HOME variable defined!
HOME=${HOME:-/root}
RVM_SH=${RVM_SH:-$HOME/.rvm/scripts/rvm}
RUBY_VERSION=${RUBY_VERSION:-2.6.3}

# rvm hates the bash options -eu

if [[ ! -f "$RVM_SH" ]]; then
    echo "Error: $0: RVM_SH $RVM_SH not found"
    exit 1
fi
set +eu
#shellcheck disable=SC1091,SC1090
. "$RVM_SH"
rvm reload
rvm install "$RUBY_VERSION"
rvm alias create default ruby-"$RUBY_VERSION"
rvm list
rvm use "$RUBY_VERSION" --default
# We don't reactivate -u because even doing a "cd" will invoke an rvm
# function in .rvm/scripts/cd that bombs with:
# .rvm/scripts/functions/environment: line 267: rvm_bash_nounset: unbound variable

set -e
ruby --version

