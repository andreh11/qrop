#!/usr/bin/env bash

source dist/env.sh

curl --ftp-create-dirs -T Qrop*x86.exe -u $FTP_USER:$FTP_PASSWD $WIN32_FTP_FILE
curl --ftp-create-dirs -T Qrop*x64.exe -u $FTP_USER:$FTP_PASSWD $WIN64_FTP_FILE
