#!/usr/bin/env bash

source ../env.sh

curl --ftp-create-dirs -T Qrop.dmg -u $FTP_USER:$FTP_PASSWD $DMG_FTP_FILE
