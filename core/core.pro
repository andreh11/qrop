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
    familymodel.cpp \
    varietymodel.cpp \
    seedcompanymodel.cpp \
    unitmodel.cpp \
    keywordmodel.cpp \
    harvestmodel.cpp \
    rolemodel.cpp \
    usermodel.cpp \
    tasktemplatemodel.cpp \
    tasktypemodel.cpp \
    taskmethodmodel.cpp \
    expensecategorymodel.cpp \
    inputmodel.cpp \
    expensemodel.cpp


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
    familymodel.h \
    varietymodel.h \
    seedcompanymodel.h \
    unitmodel.h \
    keywordmodel.h \
    harvestmodel.h \
    rolemodel.h \
    usermodel.h \
    tasktemplatemodel.h \
    tasktypemodel.h \
    taskmethodmodel.h \
    expensecategorymodel.h \
    inputmodel.h \
    expensemodel.h
