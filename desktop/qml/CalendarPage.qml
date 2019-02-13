/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Page {
    id: page

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year
    property alias rowsNumber: taskModel.rowCount
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0
    property alias listView: taskView
    property var activeCompleteButton: taskView.currentItem

    property var tableHeaderModel: [
        { name: qsTr("Plantings"),   columnName: "plantings", width: 200 },
        { name: qsTr("Locations"),   columnName: "locations", width: 200 },
        { name: qsTr("Description"), columnName: "descr", width: 200 },
        { name: qsTr("Due Date"),    columnName: "assigned_date", width: 100}
    ]

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = taskView.contentY
        taskModel.refresh();
        taskView.contentY = currentY
    }

    title: qsTr("Task calendar")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: tableSortOrder = "descending"

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 1 && addButton.visible && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextWeek()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousWeek()
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousYear();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 1 && !taskView.activeFocus && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: {
            taskView.currentIndex = 0
            taskView.forceActiveFocus();
        }
    }

    Shortcut {
        sequence: "Ctrl+J"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showDoneCheckBox.toggle();
    }

    Shortcut {
        sequence: "Ctrl+K"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showDueCheckBox.toggle();
    }

    Shortcut {
        sequence: "Ctrl+L"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showOverdueCheckBox.toggle();
    }

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
//        height: parent.height
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: page.refresh()
        week: page.week
        year: page.year
    }

    Settings {
        id: settings
        property bool showSeedCompanyBesideVariety
        property bool useStandardBedLength
        property int standardBedLength
    }

    Component {
        id: sectionHeading
        Rectangle {
            width: parent.width
            height: Units.rowHeight
            //            color: Material.color(Material.Green, Material.Shade200)
            color: Material.color(Material.Grey, Material.Shade100)
            radius: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                //                leftPadding: 16
                text: section
                color: Material.accent
                font.bold: true
                font.pixelSize: Units.fontSizeTitle
                font.family: "Roboto Regular"
            }
        }
    }

    Popup {
        id: calendarPopup
        property int taskId: -1

        y: page.activeCompleteButton ? page.activeCompleteButton.y : 0
        x: page.activeCompleteButton ? page.activeCompleteButton.x : 0
        width: contentItem.width
        height: contentItem.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        margins: 0

        contentItem: CalendarView {
            id: calendarView

            clip: true
            year: page.year
            month: (new Date()).getMonth()

            onDateSelect: {
                calendarPopup.close();
                Task.completeTask(calendarPopup.taskId, newDate)
                page.refresh();
            }
        }
    }

    Pane {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        padding: 0
        Material.elevation: 1

        Rectangle {
            id: buttonRectangle
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: 48

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: Units.smallSpacing
                visible: !filterMode

                Label {
                    text: qsTr("%L1 task(s) selected", "", checks).arg(checks)
                    leftPadding: 16
                    color: Material.color(Material.Blue)
                    Layout.fillWidth: true
                    visible: checks > 0
                    font.family: "Roboto Regular"
                    font.pixelSize: 16
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }

                Button {
                    id: addButton
                    text: qsTr("Add task")
                    flat: true
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    Material.foreground: Material.accent
                    font.pixelSize: Units.fontSizeBodyAndButton
                    visible: checks === 0
                    MouseArea {
                        id: mouseArea
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                    }
                    onClicked:  taskDialog.addTask()
                }

                SearchField {
                    id: filterField
                    placeholderText: qsTr("Search Tasks")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhPreferLowercase
                    visible: !checks
                }

                CheckBox {
                    id: showDoneCheckBox
                    text: qsTr("Done")
                }

                CheckBox {
                    id: showDueCheckBox
                    checked: true
                    text: qsTr("Due")
                }

                CheckBox {
                    id: showOverdueCheckBox
                    text: qsTr("Overdue")
                }

                WeekSpinBox {
                    id: weekSpinBox
                    week: MDate.currentWeek();
                    year: MDate.currentYear();
                }

                IconButton {
                    text: "\ue3c9" // edit
                    visible: checks > 0
                }

                IconButton {
                    text: "\ue14d" // content_copy
                    visible: checks > 0
                }

                IconButton {
                    text: "\ue872" // delete
                    visible: checks > 0
                }
            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
            width: parent.width
        }
            Column {
                id: blankStateColumn
                z: 1
                spacing: Units.smallSpacing
                visible: !page.rowsNumber
                anchors {
                    centerIn: parent
                }

                Label {
                    id: emptyStateLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr('No tasks for this week')
                    font { family: "Roboto Regular"; pixelSize: Units.fontSizeTitle }
                    color: Qt.rgba(0, 0, 0, 0.8)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: qsTr("Add")
                    flat: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    Material.background: Material.accent
                    Material.foreground: "white"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    onClicked: taskDialog.addTask()
                }
            }

        ListView {
            id: taskView
            clip: true
            spacing: 4
            cacheBuffer: Units.rowHeight*2
            anchors {
                top: topDivider.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: Units.smallSpacing
                bottomMargin: Units.smallSpacing
                leftMargin: parent.width * 0.1
                rightMargin: parent.width * 0.1
            }

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

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading
            section.labelPositioning: ViewSection.CurrentLabelAtStart |  ViewSection.InlineLabels

            model: TaskModel {
                id: taskModel
                year: weekSpinBox.year
                week: weekSpinBox.week
                showDone: showDoneCheckBox.checked
                showDue: showDueCheckBox.checked
                showOverdue: showOverdueCheckBox.checked
                filterString: filterField.text
                //                sortColumn: tableHeaderModel[tableSortColumn].columnName
                //                sortOrder: tableSortOrder
            }

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: headerRectangle
                height: headerRow.height
                width: parent.width
                color: Material.color(Material.Grey, Material.Shade100)
                z: 3
                Column {
                    width: parent.width

                    Row {
                        id: headerRow
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: Units.smallSpacing

                        Item {
                            visible: true
                            id: headerCheckbox
                            anchors.verticalCenter: headerRow.verticalCenter
                            width: parent.height
                            height: width
                        }

                        Repeater {
                            model: page.tableHeaderModel

                            TableHeaderLabel {
                                text: modelData.name
                                anchors.verticalCenter: headerRow.verticalCenter
                                width: modelData.width
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                            }
                        }
                    }
                }
            }

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

                function labelText() {
                    var planting_ids = model.plantings.split(',')
                    var planting_id = Number(planting_ids[0])
                    var map = Planting.mapFromId("planting_view", planting_id);
                    var length = map['length']
                    var rows = map['rows']
                    var spacingPlants = map['spacing_plants']
                    var seedsPerHole = map['seeds_per_hole']

                    if (task_type_id === 1 || task_type_id === 3) {
                        if (settings.useStandardBedLength) {
                            var beds = length/settings.standardBedLength
                            return qsTr("%L1 bed: ", "", beds).arg(beds) + qsTr("%L1 rows X %L2 cm").arg(rows).arg(spacingPlants)
                        } else {
                            return qsTr("%L1 bed m, %L2 rows X %L3 cm").arg(length).arg(rows).arg(spacingPlants)
                        }
                    } else if (task_type_id === 2) {
                        if (seedsPerHole > 1)
                            return qsTr("%L1 x %L2, %L3 seeds per cell").arg(map["trays_to_start"]).arg(map['tray_size']).arg(seedsPerHole)
                        else
                            return qsTr("%L1 x %L2").arg(map["trays_to_start"]).arg(map['tray_size'])

                    } else {
                        return qsTr("%1%2%3").arg(model.method).arg(model.implement ? ", " : "").arg(model.implement)
                    }
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

                            // TODO: notes handling
//                            MyToolButton {

//                                id: noteButton
//                                anchors.verticalCenter: parent.verticalCenter
//                                text: "\uf249"
//                                font.family: "Font Awesome 5 Free Solid"
//                                visible: !model.done
//                                onClicked: {
//                                    Task.delay(model.task_id, -1);
//                                    refresh();
//                                }
//                                ToolTip.text: qsTr("Show notes")
//                                ToolTip.visible: hovered
//                            }

                            MyToolButton {
                                id: backwardDelayButton
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !model.done
                                text: "\ue314"
                                font.family: "Material Icons"
                                font.pointSize: Units.fontSizeBodyAndButton
                                onClicked: {
                                    Task.delay(model.task_id, -1);
                                    page.refresh();
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
                                    page.refresh();
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
                                    page.refresh();
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
                                    page.refresh();
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
                                    sowingDate: Planting.sowingDate(plantingId)
                                    endHarvestDate: Planting.endHarvestDate(plantingId)
                                    year: page.year
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

                            Label {
                                text: firstPlantingId > 0
                                      ? Location.fullName(Location.locations(firstPlantingId))
                                      : Location.fullName(locationIdList)

                                elide: Text.ElideRight
                                width: tableHeaderModel[1].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            //                        TableLabel {
                            //                            text: model.type
                            //                            elide: Text.ElideRight
                            //                            width: tableHeaderModel[0].width
                            //                            anchors.verticalCenter: parent.verticalCenter
                            //                        }


                            Label {
                                text: labelText()
                                elide: Text.ElideRight
                                width: tableHeaderModel[2].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: MDate.formatDate(model.assigned_date, year, "")
                                elide: Text.ElideRight
                                width: tableHeaderModel[3].width
                                anchors.verticalCenter: parent.verticalCenter
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
                                        year: page.year
                                        sowingDate: Planting.sowingDate(plantingId)
                                        endHarvestDate: Planting.endHarvestDate(plantingId)
                                        showOnlyDates: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Label {
                                        text: Location.fullName(Location.locations(Number(modelData)))
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
    }
}
