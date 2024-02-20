#!/bin/bash

set -e

readonly thisDir=$(cd $(dirname $0); pwd)

TRAVIS=false
for ARG in "$@"; do
  case "$ARG" in
    -travis)
      TRAVIS=true
      ;;
  esac
done

cd $(dirname $0)/../..

DIST="$(pwd)/dist"

buildYelon() {
  ./scripts/ci/build-yelon.sh
}

buildYelon
