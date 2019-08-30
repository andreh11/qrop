include_directories(.)
find_package(Qt5 COMPONENTS Core Quick Gui Sql PrintSupport LinguistTools REQUIRED)
add_definitions(-DCORE_LIBRARY)

add_library(core SHARED
        cropmodel.cpp
        databaseutility.cpp
        db.cpp
        expensecategorymodel.cpp
        expensemodel.cpp
        family.cpp
        familymodel.cpp
        harvestmodel.cpp
        inputmodel.cpp
        keyword.cpp
        keywordmodel.cpp
        location.cpp
        locationmodel.cpp
        mdate.cpp
        nametree.cpp
        note.cpp
        notemodel.cpp
        pictureimageprovider.cpp
        planting.cpp
        plantingmodel.cpp
        print.cpp
        rolemodel.cpp
        seedcompanymodel.cpp
        seedlistmodel.cpp
        seedlistmonthmodel.cpp
        seedlistquartermodel.cpp
        sortfilterproxymodel.cpp
        task.cpp
        taskimplementmodel.cpp
        taskmethodmodel.cpp
        taskmodel.cpp
        tasktemplatemodel.cpp
        tasktypemodel.cpp
        transplantlistmodel.cpp
        treemodel.cpp
        unitmodel.cpp
        usermodel.cpp
        variety.cpp
        varietymodel.cpp
        buildinfo.cpp
        helpers.cpp
        seedcompany.cpp
        sqltablemodel.cpp
        tasktemplate.cpp
        templatetask.cpp
        templatetaskmodel.cpp
	core_resources.qrc)

target_link_libraries(core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Sql Qt5::PrintSupport)
