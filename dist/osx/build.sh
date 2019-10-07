#!/bin/bash

export BUILD_DIR=$PWD
cmake . -DCMAKE_BUILD_TYPE=Release 
make -j4
# mkdir -p deploy/usr/bin deploy/usr/lib deploy/usr/share;
mkdir deploy/usr/share/applications;
find . \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
# cp -R core/* qrop deploy/usr/bin
# cp logo.png deploy/qrop.png
# cp dist/Qrop.desktop deploy/usr/share/applications
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
macdeployqt Qrop.app -libpath=$BUILD_DIR/core -qmldir=$BUILD_DIR/desktop/qml -verbose 2 -dmg
tree
