include_directories(.)
find_package(Qt5 COMPONENTS Core Quick Gui Sql PrintSupport LinguistTools Test REQUIRED)

include_directories("${PROJECT_SOURCE_DIR}/core")

function(TEST NAME FILE)
#    get_filename_component(HDR "${FILE}" NAME_WE)
    add_executable(${NAME} ${FILE})
    add_test(NAME ${NAME} COMMAND ${NAME})
    target_link_libraries(${NAME} PRIVATE core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Widgets Qt5::Test)
endfunction()

TEST(TstDatabase tst_database.cpp)
TEST(TstMDate tst_mdate.cpp)
