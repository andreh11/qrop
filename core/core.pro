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
    expensemodel.cpp \
    db.cpp \
    databaseutility.cpp \
    planting.cpp \
    task.cpp \
    location.cpp \
    sortfilterproxymodel.cpp \
    variety.cpp \
    keyword.cpp \
    mdate.cpp \
    taskimplementmodel.cpp \
    treemodel.cpp \
    nametree.cpp


HEADERS += \
    core_global.h \
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
    expensemodel.h \
    db.h \
    databaseutility.h \
    planting.h \
    task.h \
    location.h \
    sortfilterproxymodel.h \
    variety.h \
    keyword.h \
    mdate.h \
    taskimplementmodel.h \
    treemodel.h \
    nametree.h


RESOURCES += \
    core_resources.qrc
