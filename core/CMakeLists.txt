cmake_minimum_required(VERSION 3.1)

project(qrop LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#include_directories(.)

find_package(Qt5 COMPONENTS Core Quick Gui Sql PrintSupport REQUIRED)

add_library(core SHARED
        core_global.h
	sqltablemodel.cpp 
	taskmodel.cpp 
	notemodel.cpp 
	locationmodel.cpp 
	plantingmodel.cpp 
	cropmodel.cpp 
	familymodel.cpp 
	varietymodel.cpp 
	seedcompanymodel.cpp 
	unitmodel.cpp 
	keywordmodel.cpp 
	harvestmodel.cpp 
	rolemodel.cpp 
	usermodel.cpp 
	tasktemplatemodel.cpp 
	tasktypemodel.cpp 
	taskmethodmodel.cpp 
	expensecategorymodel.cpp 
	inputmodel.cpp 
	expensemodel.cpp 
	db.cpp 
	databaseutility.cpp 
	planting.cpp 
	task.cpp 
	location.cpp 
	sortfilterproxymodel.cpp 
	variety.cpp 
	keyword.cpp 
	mdate.cpp 
	taskimplementmodel.cpp 
	treemodel.cpp 
	nametree.cpp 
	family.cpp 
	note.cpp 
	pictureimageprovider.cpp 
	seedlistmodel.cpp 
	transplantlistmodel.cpp 
	print.cpp
	core_resources.qrc)

target_link_libraries(core Qt5::Core Qt5::Quick Qt5::Gui Qt5::Sql Qt5::PrintSupport)
