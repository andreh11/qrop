#!/usr/bin/env bash

source dist/env.sh

if [ "$arch" == "x86" ]; then
    curl --ftp-create-dirs -T Qrop.exe -u $FTP_USER:$FTP_PASSWD $WIN32_FTP_FILE
else
    curl --ftp-create-dirs -T Qrop.exe -u $FTP_USER:$FTP_PASSWD $WIN64_FTP_FILE
fi
