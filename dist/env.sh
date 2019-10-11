#!/usr/bin/env bash

QROP_COMMIT=$(git rev-parse HEAD)

EXE_BASENAME=Qrop-${EXE_VERSION}

if [ "$QROP_BUILD_TYPE" == "snapshot" ]; then
    QROP_DIR=snapshots
    EXE_BASENAME=Qrop-nightly
else
    QROP_VERSION=$(git describe --tags)
    QROP_DIR="releases/${QROP_VERSION}"
    EXE_VERSION=$(echo $QROP_VERSION | tr -d 'v')
    EXE_BASENAME=Qrop-${EXE_VERSION}
fi

APPIMAGE_NAME=${EXE_BASENAME}-x86_64.AppImage
APPIMAGE_FTP_FILE=ftp://${FTP_HOST}/httpdocs/${QROP_DIR}/${APPIMAGE_NAME}
DMG_NAME=${EXE_BASENAME}.dmg
DMG_FTP_FILE=ftp://${FTP_HOST}/httpdocs/${QROP_DIR}/${DMG_NAME}
WIN32_NAME=${EXE_BASENAME}-x86.exe
WIN32_FTP_FILE=ftp://${FTP_HOST}/httpdocs/${QROP_DIR}/${WIN32_NAME}
WIN64_NAME=${EXE_BASENAME}-x64.exe
WIN64_FTP_FILE=ftp://${FTP_HOST}/httpdocs/${QROP_DIR}/${WIN64_NAME}

HTTP_DIR=https://qrop.ouvaton.org/${QROP_DIR}
APPIMAGE_URL=${HTTP_DIR}/${APPIMAGE_NAME}
DMG_URL=${HTTP_DIR}/${DMG_NAME}
WIN32_URL=${HTTP_DIR}/${WIN32_NAME}
WIN64_URL=${HTTP_DIR}/${WIN64_NAME}

