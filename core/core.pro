QT       += sql
QT       -= gui

TARGET = core
TEMPLATE = lib
CONFIG += lib c++11

DEFINES += CORE_LIBRARY

SOURCES += \
    sqltaskmodel.cpp \
    sqlnotemodel.cpp \
    sqlplantingmodel.cpp \
    planting.cpp \
    plantingdao.cpp \
    location.cpp \
    locationdao.cpp \
    plantingmodel.cpp \
    databasemanager.cpp


HEADERS += \
    core_global.h \
    sqltaskmodel.h \
    sqlnotemodel.h \
    sqlplantingmodel.h \
    planting.h \
    plantingdao.h \
    location.h \
    locationdao.h \
    plantingmodel.h \
    databasemanager.h
