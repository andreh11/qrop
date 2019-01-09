#!/bin/bash

export BUILD_DIR=$PWD
mkdir build;
cd build;
qmake -config release ..;
make -j 8;
mkdir -p deploy/usr/bin deploy/usr/lib deploy/usr/share;
mkdir deploy/usr/share/applications;
find . \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
cp -R core/* desktop/* deploy/usr/bin
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
ls $BUILD_DIR/core
macdeployqt deploy/usr/bin/desktop.app -libpath=$BUILD_DIR/core -qmldir=$BUILD_DIR/desktop/qml
tree
