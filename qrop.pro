TEMPLATE = subdirs

SUBDIRS += \
  core
  desktop
#  mobile

desktop.depends = core
#mobile.depends = core
