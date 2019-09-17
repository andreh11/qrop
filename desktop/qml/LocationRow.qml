import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Row {
    id: row

    height: Units.rowHeight
    spacing: Units.smallSpacing
    leftPadding: 16

//    property alias year: timeline.year
//    property alias
    
    Timeline {
        id: timeline
        height: parent.height
        visible: view.showTimeline
        year: view.year
        season: view.season
        showGreenhouseSow: false
        showNames: true
        showTasks: locationSettings.showTasks
        showOnlyActiveColor: true
        showFamilyColor: view.showFamilyColor
        dragActive: true
        plantingIdList: locationModel.plantings(styleData.index, season, year)
        taskIdList: locationModel.tasks(styleData.index, season, year)
        locationId: locationModel.locationId(styleData.index)
        onDragFinished: treeView.draggedPlantingId = -1
        onPlantingMoved: {
            locationModel.refreshIndex(styleData.index)
            view.plantingMoved()
        }
        onPlantingRemoved: {
            locationModel.refreshIndex(styleData.index)
            view.plantingRemoved()
        }
    }
}
