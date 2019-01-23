##!/usr/bin/env bash

BUILD_DIR=$PWD
mkdir build;
cd build;
qmake -config release ..;
make -j 8;
mkdir -p deploy/usr/bin deploy/usr/lib deploy/usr/share;
mkdir deploy/usr/share/applications;
cp -R core/*so* desktop/* deploy/usr/bin
find . \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
cd deploy;
cp ../../logo.png desktop.png
cp ../../dist/Qrop.desktop usr/share/applications
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/5/linuxdeployqt-5-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage;
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
./linuxdeployqt*.AppImage usr/share/applications/Qrop.desktop -verbose=2 -qmldir=$BUILD_DIR/desktop/qml -bundle-non-qt-libs -extra-plugins=sqldrivers,imageformats/libqsvg.so
./linuxdeployqt*.AppImage usr/share/applications/Qrop.desktop -verbose=2 -qmldir=$BUILD_DIR/desktop/qml -appimage
find . | grep AppImage;
