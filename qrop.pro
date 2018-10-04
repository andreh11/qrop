TEMPLATE = subdirs

SUBDIRS += \
  core \
  desktop
#  mobile

#desktop.depends = core
#mobile.depends = core
win32:target.path = $$PREFIX
win32:!isEmpty(target.path): INSTALLS += target

