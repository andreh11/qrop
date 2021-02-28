#!/usr/bin/env bash

source dist/env.sh

if [ "$WINDOWS_ARCH" == "32bit" ]; then
    curl --ftp-create-dirs -T Qrop.exe -u $FTP_USER:$FTP_PASSWD $WIN32_FTP_FILE
else
    curl --ftp-create-dirs -T Qrop.exe -u $FTP_USER:$FTP_PASSWD $WIN64_FTP_FILE
fi