#!/bin/bash

export BUILD_DIR=$PWD
export APP_NAME=Qrop
npm install -g appdmg
cmake . -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET="10.8" -DCMAKE_CXX_FLAGS="-stdlib=libc++"
make -j4
find . \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
macdeployqt qrop.app -qmldir=$BUILD_DIR/desktop/qml -verbose=2 -executable="${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
mv qrop.app Qrop.app
cp dist/osx/DiskImage/layout.json .
appdmg layout.json Qrop.dmg
ls Qrop*
