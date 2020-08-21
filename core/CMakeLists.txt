include_directories(.)
find_package(Qt5
    REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Sql
    PrintSupport
    LinguistTools)
add_definitions(-DCORE_LIBRARY)

add_library(core SHARED
        buildinfo.cpp
        core_resources.qrc
        helpers.cpp
        mdate.cpp
        nametree.cpp
        print.cpp
        qrpimageprovider.cpp
        tableprinter.cpp

        dbutils/db.cpp
        dbutils/databaseutility.cpp
        dbutils/family.cpp
        dbutils/keyword.cpp
        dbutils/location.cpp
        dbutils/note.cpp
        dbutils/planting.cpp
        dbutils/seedcompany.cpp
        dbutils/task.cpp
        dbutils/tasktemplate.cpp
        dbutils/templatetask.cpp
        dbutils/variety.cpp

        models/cropmodel.cpp
        models/cropstatmodel.cpp
        models/expensecategorymodel.cpp
        models/expensemodel.cpp
        models/familymodel.cpp
        models/harvestmodel.cpp
        models/inputmodel.cpp
        models/keywordmodel.cpp
        models/locationmodel.cpp
        models/notemodel.cpp
        models/plantingmodel.cpp
        models/qquicktreemodeladaptor.cpp
        models/recordmodel.cpp
        models/rolemodel.cpp
        models/seedcompanymodel.cpp
        models/seedlistmodel.cpp
        models/seedlistmonthmodel.cpp
        models/seedlistquartermodel.cpp
        models/sortfilterproxymodel.cpp
        models/sqltablemodel.cpp
        models/taskimplementmodel.cpp
        models/taskmethodmodel.cpp
        models/taskmodel.cpp
        models/tasktemplatemodel.cpp
        models/tasktypemodel.cpp
        models/templatetaskmodel.cpp
        models/transplantlistmodel.cpp
        models/treemodel.cpp
        models/unitmodel.cpp
        models/usermodel.cpp
        models/varietymodel.cpp
        )


target_link_libraries(core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Sql Qt5::PrintSupport)
