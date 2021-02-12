# This is a template of configuration file for MXE. See
# index.html for more extensive documentations.

# This variable controls the number of compilation processes
# within one package ("intra-package parallelism").
JOBS := 8

# This variable controls the targets that will build.
MXE_TARGETS :=  x86_64-w64-mingw32.shared i686-w64-mingw32.shared

# The three lines below makes `make` build these "local packages" instead of all packages.
# The ordering of the list appears weird, but this seems to help to get the build done
# faster on a massively parallel machine to get some of the bottleneck packages built as
# early as possible
LOCAL_PKG_LIST := gcc \
                  openssl \
                  qtbase \
                  nsis \
                  curl \
                  libzip \
                  libgit2 \
                  qtconnectivity \
                  qtcharts \
                  qtdeclarative \
                  qtimageformats \
                  qtquickcontrols \
                  qtquickcontrols2 \
                  qttools \
                  qttranslations \
                  zstd
.DEFAULT local-pkg-list:
local-pkg-list: $(LOCAL_PKG_LIST)