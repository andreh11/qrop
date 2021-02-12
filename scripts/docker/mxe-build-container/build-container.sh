#!/bin/bash
set -x
set -e

# known good MXE sha
# MXE_SHA="8966a64"
SCRIPTPATH=$(dirname $0)

# version of the docker image
VERSION=5.15-shared

pushd $SCRIPTPATH
docker build -t andreh11/qt-mxe:$VERSION -f Dockerfile .
popd
