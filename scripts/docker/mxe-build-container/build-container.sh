#!/bin/bash
set -x
set -e

# known good MXE sha
MXE_SHA="8966a64"
SCRIPTPATH=$(dirname $0)

# version of the docker image
VERSION=1.0

pushd $SCRIPTPATH

# we use the 'experimental' --squash argument to significantly reduce the size of the massively huge
# Docker container this produces
docker build -t andreh11/mxe-build-container:$VERSION --build-arg=mxe_sha=$MXE_SHA -f Dockerfile .
popd