##!/usr/bin/env bash

mkdir build;
cd build;
qmake -config release ..;
make -j 8;
mkdir -p deploy/usr/bin deploy/usr/lib deploy/usr/share;
mkdir usr/share/applications;
find build \( -name "moc_*" -or -name "*.o" -or -name "qrc_*" -or -name "Makefile*" -or -name "*.a" \) -exec rm {} \;
cp -R build/core/* build/desktop/* deploy/usr/bin
cd deploy;
cp ../../logo.png desktop.png
cp ../../dist/Qrop.desktop usr/share/applications
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage";
chmod a+x linuxdeployqt*.AppImage;
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH;
./linuxdeployqt*.AppImage usr/share/applications/Qrop.desktop -verbose=2 -qmldir=/home/ah/src/qrop/desktop/qml -bundle-non-qt-libs -extra-plugins=sqldrivers,imageformats/libqsvg.s
./linuxdeployqt*.AppImage usr/share/applications/Qrop.desktop -verbose=2 -qmldir=/home/ah/src/qrop/desktop/qml -appimage
find . | grep AppImage;
