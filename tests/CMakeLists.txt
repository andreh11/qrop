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
TEST(TstQml tst_qml.cpp)
