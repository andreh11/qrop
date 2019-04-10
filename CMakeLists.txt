cmake_minimum_required(VERSION 3.1)

project(qrop LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QROP_MAJOR_VERSION 0)
set(QROP_MINOR_VERSION 2)
set(QROP_PATCH_VERSION 0)

string(TIMESTAMP BUILD_DATE %Y%m)

include_directories("${PROJECT_SOURCE_DIR}/core")
add_subdirectory(core)

find_package(Qt5 COMPONENTS Core Quick Gui Widgets Qml Quick Sql REQUIRED)

set(desktop_SRCS
    desktop/main.cpp
    desktop/qropdoublevalidator.cpp
    desktop/qml.qrc
    desktop/resources.qrc)

add_executable(${PROJECT_NAME} ${desktop_SRCS})
target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Widgets Qt5::Qml Qt5::Quick Qt5::Sql)
