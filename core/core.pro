QT       += sql
QT       -= gui

TARGET = core
TEMPLATE = lib
CONFIG += lib c++11

DEFINES += CORE_LIBRARY

SOURCES += \
#    databasemanager.cpp \
    sqltablemodel.cpp \
    taskmodel.cpp \
    notemodel.cpp \
    locationmodel.cpp \
    plantingmodel.cpp \
    cropmodel.cpp \
    familymodel.cpp


HEADERS += \
    core_global.h \
    planting.h \
#    databasemanager.h \
    sqltablemodel.h \
    taskmodel.h \
    notemodel.h \
    locationmodel.h \
    plantingmodel.h \
    cropmodel.h \
    familymodel.h
