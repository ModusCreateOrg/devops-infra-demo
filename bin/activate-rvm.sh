#!/usr/bin/env bash
# Activate rvm
# Source this to activate RVM

RVM_SH=${RVM_SH:-$HOME/.rvm/shell/rvm}
RUBY_VERSION=${RUBY_VERSION:-2.6.3}

# rvm hates the bash options -eu
set +eu
#shellcheck disable=SC1091,SC1090
. "$RVM_SH"
rvm reload
rvm install "$RUBY_VERSION"
rvm alias create default ruby-"$RUBY_VERSION"
rvm list
rvm use "$RUBY_VERSION" --default
set -eu
ruby --version

