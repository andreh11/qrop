QT       += sql
QT       -= gui

TARGET = core
TEMPLATE = lib
CONFIG += lib c++11

DEFINES += CORE_LIBRARY

SOURCES += \
    sqltaskmodel.cpp \
    sqlnotemodel.cpp \
    sqlplantingmodel.cpp


HEADERS += \
    core_global.h \
    sqltaskmodel.h \
    sqlnotemodel.h \
    sqlplantingmodel.h


