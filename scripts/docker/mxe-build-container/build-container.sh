#!/bin/bash
set -x
set -e

# known good MXE sha
# MXE_SHA="8966a64"
SCRIPTPATH=$(dirname $0)

# version of the docker image
VERSION=5.15-static

pushd $SCRIPTPATH
docker build -t andreh11/mxe-build-container:$VERSION -f Dockerfile .
popd
