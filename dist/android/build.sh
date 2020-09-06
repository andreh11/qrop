##!/usr/bin/env bash
# Android build script for Qrop.

BUILD_DIR=$PWD
cmake . -DCMAKE_BUILD_TYPE=Release -G Ninja "-DCMAKE_PREFIX_PATH:PATH=${QT_DESKTOP}"
cmake -G Ninja -DCMAKE_BUILD_TYPE:STRING=Release -DANDROID_ABI:STRING=armeabi-v7a -DANDROID_BUILD_ABI_arm64-v8a:BOOL=ON -DANDROID_BUILD_ABI_x86:BOOL=ON -DANDROID_BUILD_ABI_x86_64:BOOL=ON "-DANDROID_NATIVE_API_LEVEL:STRING=${ANDROID_NATIVE_API_LEVEL}" "-DANDROID_SDK:PATH=${ANDROID_SDK_ROOT}" "-DANDROID_NDK:PATH=${ANDROID_NDK_ROOT}" "-DCMAKE_PREFIX_PATH:PATH=${QT_ANDROID}" "-DCMAKE_FIND_ROOT_PATH:STRING=${QT_ANDROID}" "-DCMAKE_TOOLCHAIN_FILE:PATH=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake"
make -j$(nproc);
make install INSTALL_ROOT=$HOME/dist
#androiddeployqt --input android-libMyAppName.so-deployment-settings.json --output dist/ --android-platform $SDK_PLATFORM --deployment bundled --gradle --release
