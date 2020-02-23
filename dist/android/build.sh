##!/usr/bin/env bash
# Android build script for Qrop.

BUILD_DIR=$PWD
cmake . -DCMAKE_BUILD_TYPE=Release 
make -j$(nproc);
