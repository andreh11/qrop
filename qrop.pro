TEMPLATE = subdirs

SUBDIRS += \
  core \
  desktop \
    tests

desktop.depends = core

#win32:target.path = $$PREFIX
#win32:!isEmpty(target.path): INSTALLS += target

#win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/core/release/ -lcore
#else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/core/debug/ -lcore
#else:unix: LIBS += -L$$OUT_PWD/core/ -lcore

#INCLUDEPATH += $$PWD/core
#DEPENDPATH += $$PWD/core
