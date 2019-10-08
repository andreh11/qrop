#!/usr/bin/env bash

source dist/env.sh

curl --ftp-create-dirs -T Qrop*.AppImage -u $FTP_USER:$FTP_PASSWD $APPIMAGE_FTP_FILE
