#!/usr/bin/env bash

source dist/env.sh

echo "Sending Qrop.dmg to ${QROP_DIR}"
curl --ftp-create-dirs -T Qrop.dmg -u $FTP_USER:$FTP_PASSWD $DMG_FTP_FILE
