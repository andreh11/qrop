QT       += sql
QT       -= gui

TARGET = core
TEMPLATE = lib
CONFIG += lib c++11

DEFINES += CORE_LIBRARY

SOURCES += \
    sqltaskmodel.cpp \
    sqlnotemodel.cpp \
#    databasemanager.cpp \
    plantingmodel.cpp \
    cropmodel.cpp \
    sqltablemodel.cpp


HEADERS += \
    core_global.h \
    sqltaskmodel.h \
    sqlnotemodel.h \
#    databasemanager.h \
    plantingmodel.h \
    cropmodel.h \
    sqltablemodel.h
