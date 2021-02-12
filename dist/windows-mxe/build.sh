##!/usr/bin/env bash
# MXE cross-compile build script for Qrop.

set -x
set -e

BUILD_DIR=$PWD

if [ "$WINDOWS_ARCH" == "32bit" ]; then
    MINGW_PREFIX=i686-w64-mingw32.shared
else
    MINGW_PREFIX=x86_64-w64-mingw32.shared
fi

DLL_DIR="/usr/lib/mxe/usr/${MINGW_PREFIX}/bin/"
${MINGW_PREFIX}-cmake . -DCMAKE_BUILD_TYPE=Release 
make -j$(nproc) qrop
mkdir release
cp qrop.exe release
cp core/libcore.dll release

git clone https://github.com/saidinesh5/mxedeployqt
./mxedeployqt/mxedeployqt \
    --qtplugins="graphicaleffects;platforms;sqldrivers;styles" \
    --additionallibs="icudt66.dll;icuin66.dll;icuuc66.dll;" \
    --skiplibs="qsqlmysql.dll;qsqlodbc.dll;qsqlpsql.dll;qsqltds.dll" \
    --mxepath=/usr/lib/mxe/usr \
    --mxetarget=${MINGW_PREFIX} \
    --qmlrootpath=$PWD/desktop/qml release

cp $DLL_DIR/opengl32.dll release

if [ "$WINDOWS_ARCH" == "32bit" ]; then
   cp $DLL_DIR/libssl-1_1.dll release
else
   cp $DLL_DIR/libssl-1_1-x64.dll release
fi

${MINGW_PREFIX}-makensis Qrop.nsi