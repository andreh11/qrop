cmake_minimum_required(VERSION 3.5)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QROP_VERSION_MAJOR 0)
set(QROP_VERSION_MINOR 4)
set(QROP_VERSION_MICRO 1)
set(QROP_VERSION "${QROP_VERSION_MAJOR}.${QROP_VERSION_MINOR}.${QROP_VERSION_MICRO}")

# Basic functions and other bundle stuffs for Mac and Windows
include(QtCommon)

# Project informations
project(qrop LANGUAGES CXX VERSION ${QROP_VERSION})
fix_project_version()
set(COMPANY "L'Atelier paysan")
set(COPYRIGHT "Copyright (c) 2018-2019 André Hoarau")

option(MAKE_TESTS "Make the tests" ON)

# Get the current working branch
execute_process(
  COMMAND git rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
  COMMAND git log -1 --format=%h
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the complete revision information
execute_process(
  COMMAND git describe --tags
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_REVISION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the shot version number
execute_process(
    COMMAND sh "-c" "git describe --abbrev=0 --tag | tr -d \"v\""
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_VERSION_NUMBER
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (WIN32)
    # Configure NSIS script
    configure_file("${PROJECT_SOURCE_DIR}/dist/windows/Qrop.nsi.in" "${PROJECT_SOURCE_DIR}/Qrop.nsi" @ONLY)
endif()

configure_file(
  ${CMAKE_SOURCE_DIR}/core/version.h.in
  ${CMAKE_SOURCE_DIR}/core/version.h
)

string(TIMESTAMP BUILD_DATE %Y%m)

include_directories(lib)
include_directories("${PROJECT_SOURCE_DIR}/core")
add_subdirectory(core)

find_package(Qt5 REQUIRED COMPONENTS
    Core
    Quick
    QuickControls2
    Gui
    Widgets
    Qml
    Quick
    Sql)

set(SOURCE_FILES
    desktop/main.cpp
    desktop/qropdoublevalidator.cpp
    desktop/timevalidator.cpp
    desktop/resources.qrc)

add_project_meta(META_FILES_TO_INCLUDE)

if (WIN32 OR CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(QML_FILES desktop/qml.qrc)
endif()

# Compile QML code for release only on Unix and Mac (doesn't work on Windows).
if((APPLE OR UNIX) AND CMAKE_BUILD_TYPE STREQUAL "Release")
    find_package(Qt5QuickCompiler)
    qtquick_compiler_add_resources(QML_FILES desktop/qml.qrc)
endif()

add_executable(${PROJECT_NAME} ${OS_BUNDLE} ${SOURCE_FILES} ${META_FILES_TO_INCLUDE} ${QML_FILES})
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Widgets Qt5::Qml Qt5::Quick Qt5::Sql)

if(MAKE_TESTS)
    enable_testing(true)
    include_directories("${PROJECT_SOURCE_DIR}/tests")
    add_subdirectory(tests)
endif()
