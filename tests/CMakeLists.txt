include_directories(.)
find_package(Qt5 COMPONENTS Core Quick Gui Sql PrintSupport LinguistTools Test QuickTest REQUIRED)

include_directories("${PROJECT_SOURCE_DIR}/core" "${PROJECT_SOURCE_DIR}/desktop")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

function(TEST NAME FILE)
#    get_filename_component(HDR "${FILE}" NAME_WE)
    add_executable(${NAME} ${FILE})
    add_test(NAME ${NAME} COMMAND ${NAME} WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/tests)
    target_link_libraries(${NAME} PRIVATE core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Widgets Qt5::Test Qt5::QuickTest)
endfunction()


TEST(TstDatabase tst_database.cpp)
TEST(TstQrpDate tst_qrpdate.cpp)
TEST(TstHelpers tst_helpers.cpp)

if(APPLE OR UNIX) # QML tests don't seem to compile properly on Windows.
    # This is needed for Qt Creator to see Qt Quick tests.
    # no need to copy around qml test files for shadow builds - just set the respective define
    add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
    TEST(TstQml tst_qml.cpp)
endif()



