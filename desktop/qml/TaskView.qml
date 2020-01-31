import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

ListView {
    id: taskView

    property alias week: taskModel.week
    property alias year: taskModel.year
    property alias showDone: taskModel.showDone
    property alias showOverdue: taskModel.showOverdue
    property alias showDue: taskModel.showDue
    property alias filterString: taskModel.filterString
    property var activeCompleteButton: taskView.currentItem
    property alias rowCount: taskModel.rowCount
    property alias plantingId: taskModel.plantingId

    property var tableHeaderModel: [
        { name: qsTr("Plantings"),   columnName: "plantings", width: 200 },
        { name: qsTr("Locations"),   columnName: "locations", width: 200 },
        { name: qsTr("Description"), columnName: "descr", width: 200 },
        { name: qsTr("Due Date"),    columnName: "assigned_date", width: 100}
    ]

    property int tableSortColumn: 3
    property string tableSortOrder: "ascending"

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = taskView.contentY
        taskModel.refresh();
        taskView.contentY = currentY
    }

    clip: true
    spacing: 4
    cacheBuffer: Units.rowHeight*2
    
    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        visible: taskView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }
    
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    
    ScrollBar.vertical: ScrollBar {
        visible: largeDisplay
        parent: taskView.parent
        anchors.top: taskView.top
        anchors.left: taskView.right
        anchors.bottom: taskView.bottom
    }
    
    Keys.onSpacePressed: {
        if (event.modifiers & Qt.ControlModifier)
            currentItem.completeButton.pressAndHold()
        else
            currentItem.completeButton.clicked()
    }
    
    Keys.onPressed: {
        if (event.key === Qt.Key_E)
            currentItem.editTask()
        if (event.key === Qt.Key_D)
            currentItem.detailsButton.toggle()
    }
    
    Keys.onRightPressed: currentItem.forwardDelayButton.clicked()
    Keys.onLeftPressed: currentItem.backwardDelayButton.clicked()
    Keys.onDeletePressed: currentItem.deleteButton.clicked()

    Popup {
        id: calendarPopup
        property int taskId: -1

        y: taskView.activeCompleteButton ? taskView.activeCompleteButton.y : 0
        x: taskView.activeCompleteButton ? taskView.activeCompleteButton.x : 0
        width: contentItem.width
        height: contentItem.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        margins: 0

        contentItem: CalendarView {
            id: calendarView

            clip: true
            year: taskView.year
            month: (new Date()).getMonth()

            onDateSelect: {
                calendarPopup.close();
                Task.completeTask(calendarPopup.taskId, newDate)
                taskView.refresh();
            }
        }
    }

    Component {
        id: sectionHeading
        Rectangle {
            width: parent.width
            height: Units.rowHeight
            color: Material.color(Material.Grey, Material.Shade100)
            radius: 4

            Text {
                text: section
                anchors.verticalCenter: parent.verticalCenter
                color: Material.accent
                font.bold: true
                font.pixelSize: Units.fontSizeTitle
                font.family: "Roboto Regular"
            }
        }
    }

    section.property: "type"
    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading
    section.labelPositioning: ViewSection.CurrentLabelAtStart |  ViewSection.InlineLabels
    
    model: TaskModel {
        id: taskModel
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }
    
//    headerPositioning: ListView.OverlayHeader
//    header: Rectangle {
//        id: headerRectangle
//        height: headerRow.height
//        width: parent.width
//        color: Material.color(Material.Grey, Material.Shade100)
//        z: 3
//        Column {
//            width: parent.width
            
//            Row {
//                id: headerRow
//                height: Units.rowHeight
//                spacing: Units.smallSpacing
//                leftPadding: Units.smallSpacing
                
//                Item {
//                    visible: true
//                    id: headerCheckbox
//                    anchors.verticalCenter: headerRow.verticalCenter
//                    width: parent.height
//                    height: width
//                }
                
//                Repeater {
//                    model: taskView.tableHeaderModel
                    
//                    TableHeaderLabel {
//                        text: modelData.name
//                        anchors.verticalCenter: headerRow.verticalCenter
//                        width: modelData.width
//                        state: taskView.tableSortColumn === index ? taskView.tableSortOrder : ""
//                        onNewColumn: {
//                            if (taskView.tableSortColumn !== index) {
//                                taskView.tableSortColumn = index
//                                taskView.tableSortOrder = "descending"
//                            }
//                        }
//                        onNewOrder: taskView.tableSortOrder = order
//                    }
//                }
//            }
//        }
//    }
    
    delegate: Rectangle {
        id: delegate
        
        property alias completeButton: completeButton
        property alias forwardDelayButton: forwardDelayButton
        property alias backwardDelayButton: backwardDelayButton
        property alias deleteButton: deleteButton
        property alias detailsButton: detailsButton
        
        function editTask() {
            taskDialog.editTask(model.task_id)
        }
        
        color: "white"
        border.color: Material.color(Material.Grey, Material.Shade400)
        border.width: rowMouseArea.containsMouse ? 1 : 0
        
        radius: 2
        property var plantingIdList: model.plantings.split(",")
        property var locationIdList: model.locations.split(",")
        property int firstPlantingId: plantingIdList ? Number(plantingIdList[0]) : -1
        
        height: summaryRow.height + detailsRow.height
        width: parent.width
        
        MouseArea {
            id: rowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: true
            //                    z: 3
            cursorShape: Qt.PointingHandCursor
            
            onClicked: editTask()
            
            Rectangle {
                id: taskButtonRectangle
                height: Units.rowHeight
                width: childrenRect.width
                color: "white"
                z: 2
                visible: rowMouseArea.containsMouse
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: delegate.border.width
                    bottomMargin: delegate.border.width
                    rightMargin: delegate.border.width
                }
                
                Row {
                    spacing: -16
                    anchors.verticalCenter: parent.verticalCenter
                    
                    MyToolButton {
                        id: backwardDelayButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !model.done
                        text: "\ue314"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        onClicked: {
                            Task.delay(model.task_id, -1);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Move to previous week")
                        ToolTip.visible: hovered
                    }
                    
                    MyToolButton {
                        id: forwardDelayButton
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        visible: !model.done
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            Task.delay(model.task_id, 1);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Move to next week")
                        ToolTip.visible: hovered
                    }
                    
                    MyToolButton {
                        id: deleteButton
                        text: enabled ? "\ue872" : ""
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: model.task_type_id > 3
                        onClicked: {
                            Task.remove(model.task_id);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Remove")
                        ToolTip.visible: hovered
                    }
                }
            }
            
            Column {
                id: mainColumn
                width: parent.width
                
                Row {
                    id: summaryRow
                    height: Units.rowHeight
                    spacing: Units.smallSpacing
                    leftPadding: Units.smallSpacing
                    
                    TaskCompleteButton {
                        id: completeButton
                        anchors.verticalCenter: parent.verticalCenter
                        width: height
                        overdue: model.overdue
                        done: model.done
                        due: model.due
                        
                        ToolTip.text:
                            done ? qsTr("Done on %1. Click to undo."
                                        .arg(model.completed_date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)))
                                 : qsTr("Click to complete task. Hold to select date.")
                        ToolTip.visible: hovered
                        
                        onClicked: {
                            if (done)
                                Task.uncompleteTask(model.task_id);
                            else
                                Task.completeTask(model.task_id);
                            taskView.refresh();
                        }
                        onPressAndHold: {
                            taskView.currentIndex = index
                            calendarPopup.taskId = model.task_id
                            calendarPopup.open()
                        }
                    }
                    
                    Row {
                        width: tableHeaderModel[0].width
                        anchors.verticalCenter: parent.verticalCenter

                        PlantingLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            plantingId: firstPlantingId
                            showOnlyDates: true
                            showRank: true
                            year: taskView.year
                        }
                        
                        MyToolButton {
                            id: detailsButton
                            text: "⋅⋅⋅"
                            checkable: true
                            visible: plantingIdList.length > 1
                            ToolTip.visible: hovered
                            ToolTip.text: checked ? qsTr("Hide plantings and locations details")
                                                  : qsTr("Show plantings and locations details")
                        }
                    }
                    
                    TableLabel {
                        text: firstPlantingId > 0
                              ? Location.fullNameList(Location.locations(firstPlantingId))
                              : Location.fullNameList(locationIdList)
                        
                        elide: Text.ElideRight
                        width: tableHeaderModel[1].width
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    TableLabel {
                        text: Task.description(model.task_id)
                        elide: Text.ElideRight
                        width: tableHeaderModel[2].width
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    TableLabel {
                        text: MDate.isoWeek(model.assigned_date) !== week ? MDate.formatDate(model.assigned_date, year, "")
                                                                          : MDate.dayName(model.assigned_date)
                        elide: Text.ElideRight
                        width: tableHeaderModel[3].width
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Repeater {
                        model: Keyword.keywordStringList(firstPlantingId)
                        delegate: SimpleChip {
                            text: modelData
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                Column {
                    id: detailsRow
                    visible: detailsButton.checked
                    width: parent.width
                    height: detailsButton.checked ? (plantingIdList.length - 1) * Units.rowHeight : 0
                    leftPadding: Units.smallSpacing
                    
                    Repeater {
                        model: plantingIdList.slice(1)
                        
                        Row {
                            height: Units.rowHeight
                            spacing: Units.smallSpacing
                            Item { width: completeButton.width; height: parent.height }

                            PlantingLabel {
                                width: tableHeaderModel[0].width
                                plantingId: Number(modelData)
                                showRank: true
                                year: taskView.year
                                sowingDate: Planting.sowingDate(plantingId)
                                endHarvestDate: Planting.endHarvestDate(plantingId)
                                showOnlyDates: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: Location.fullNameList(Location.locations(Number(modelData)))
                                elide: Text.ElideRight
                                width: tableHeaderModel[1].width
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
