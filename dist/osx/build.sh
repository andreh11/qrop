#!/bin/bash

export BUILD_DIR=$PWD
export APP_NAME=Qrop
npm install -g appdmg
cmake . -DCMAKE_BUILD_TYPE=Release
make -j4
# mkdir -p deploy/usr/bin deploy/usr/lib deploy/usr/share;
# mkdir deploy/usr/share/applications;
find . \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
# cp -R core/* qrop deploy/usr/bin
# cp logo.png deploy/qrop.png
# cp dist/Qrop.desktop deploy/usr/share/applications
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
# cp -R dist/osx/Qrop.app .
macdeployqt Qrop.app -qmldir=$BUILD_DIR/desktop/qml -verbose=2 -executable="${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
tree Qrop.app
cp dist/osx/DiskImage/layout.json .
appdmg layout.json Qrop.dmg
ls Qrop*
