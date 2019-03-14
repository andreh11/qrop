# without this a "make clean" would delete the .ts files
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM 1)

find_package(Qt5 COMPONENTS Core Quick Gui Sql PrintSupport LinguistTools REQUIRED)
# active translations - these will be built
#
set(TRANSLATION_FILES
    fr.ts
)
qt5_add_translations(TRANSLATIONS ${TRANSLATION_FILES)
add_custom_target(translations ALL DEPENDS ${TRANSLATIONS})
