##!/usr/bin/env bash
# Android build script for Qrop.

BUILD_DIR=$PWD
cmake . -DCMAKE_BUILD_TYPE=Release 
make -j$(nproc);
make install INSTALL_ROOT=$HOME/dist
androiddeployqt --input android-libMyAppName.so-deployment-settings.json --output dist/ --android-platform $SDK_PLATFORM --deployment bundled --gradle --release
