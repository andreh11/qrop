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

import io.croplan.components 1.0

Page {
    id: page

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year
    property alias rowsNumber: taskModel.count
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0
    property alias listView: listView

    property var tableHeaderModel: [
        { name: qsTr("Plantings"),   columnName: "plantings", width: 200 },
        { name: qsTr("Locations"),   columnName: "locations", width: 200 },
        { name: qsTr("Description"), columnName: "descr", width: 200 },
        { name: qsTr("Due Date"),    columnName: "assigned_date", width: 100}
    ]

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"

    function refresh() { taskModel.refresh(); }

    title: "Calendar"
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: tableSortOrder = "descending"

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
        height: parent.height
        x: (parent.width - width) / 2
        onAccepted: page.refresh()
        week: page.week
        year: page.year
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
        id: popup
        //                                y: control.height
        //                                x: -control.width
        width: contentItem.width
        height: contentItem.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        padding: 0
        margins: 0

        contentItem: CalendarView {
            id: calendarView

            clip: true
            year: year
            month: (new Date()).getMonth()
            date: new Date()
            //                                    month: calendarDate.getMonth()
            //                                    year: calendarDate.getFullYear()
            //                                    date: calendarDate

            onDateSelect: {
                //                                        calendarDate = newDate;
                popup.close();
                //                                        control.editingFinished();
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
                    id: searchField
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
                    week: NDate.currentWeek();
                    year: NDate.currentYear();
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

        ListView {
            id: listView
            clip: true
            spacing: 4
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

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 100 }
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0; duration: 100 }
            }

            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalAndVerticalFlick

            ScrollBar.vertical: ScrollBar {
                visible: largeDisplay
                parent: listView.parent
                anchors.top: listView.top
                anchors.left: listView.right
                anchors.bottom: listView.bottom
            }

            Shortcut {
                sequence: "Ctrl+K"
                onActivated: {
                    filterMode = true
                    filterField.focus = true
                }
            }

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
                filterString: searchField.text
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
                color: "white"
                border.color: Material.color(Material.Grey, Material.Shade400)
                border.width: rowMouseArea.containsMouse ? 1 : 0

                radius: 2
                property var idList: model.plantings.split(",")
                property int firstId: Number(idList[0])

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

                    onClicked: taskDialog.editTask(model.task_id)

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
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !model.done
                                text: "-7"
                                onClicked: {
                                    Task.delay(model.task_id, -1);
                                    refresh();
                                }
                                ToolTip.text: qsTr("Move to previous week")
                                ToolTip.visible: hovered
                            }

                            MyToolButton {
                                text: "+7"
                                visible: !model.done
                                font.family: "Roboto Condensed"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    Task.delay(model.task_id, 1);
                                    refresh();
                                }
                                ToolTip.text: qsTr("Move to next week")
                                ToolTip.visible: hovered
                            }

                            MyToolButton {
                                text: enabled ? "\ue872" : ""
                                font.family: "Material Icons"
                                font.pixelSize: 22
                                anchors.verticalCenter: parent.verticalCenter
                                enabled: model.task_type_id > 3
                                onClicked: {
                                    Task.remove(model.task_id);
                                    refresh();
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
//                                height: parent.height * 1.3
//                                width: height
                                overdue: model.overdue
                                done: model.done
                                due: model.due
                                onClicked: {
                                    if (done)
                                        Task.uncompleteTask(model.task_id);
                                    else
                                        Task.completeTask(model.task_id);
                                    taskModel.refresh();
                                }
                                onPressAndHold: {
                                    if (largeDisplay)
                                        return
                                    popup.x = completeButton.x
                                    popup.y = completeButton.y
                                    popup.open()
                                }
                            }

                            Row {
                                width: tableHeaderModel[0].width
                                anchors.verticalCenter: parent.verticalCenter
                                PlantingLabel {
                                    anchors.verticalCenter: parent.verticalCenter
                                    plantingId: firstId
                                    showOnlyDates: true
                                    sowingDate: Planting.sowingDate(plantingId)
                                    endHarvestDate: Planting.endHarvestDate(plantingId)
                                    year: page.year
                                }

                                MyToolButton {
                                    id: detailsButton
                                    text: "⋅⋅⋅"
                                    //                                flat: true
                                    checkable: true
                                    visible: idList.length > 1
                                    ToolTip.visible: hovered
                                    ToolTip.text: checked ? qsTr("Hide plantings and locations details")
                                                          : qsTr("Show plantings and locations details")
                                }
                            }

                            Label {
                                text: model.locations
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
                                text: {
                                    var planting_ids = model.plantings.split(',')
                                    var planting_id = Number(planting_ids[0])
                                    var map = Planting.mapFromId("planting_view", planting_id);
                                    var length = map['length']
                                    var rows = map['rows']
                                    var spacingPlants = map['spacing_plants']
                                    var seedsPerHole = map['seeds_per_hole']

                                    if (task_type_id === 1 || task_type_id === 3) {
                                        return "%1 bed m, %2 X %3 cm".arg(length).arg(rows).arg(spacingPlants)
                                    } else if (task_type_id === 2) {
                                        return qsTr("%L1 x %L2, %3 seed(s) per cell", "", seedsPerHole).arg(map["trays_to_start"]).arg(map['tray_size']).arg(seedsPerHole)
                                    } else {
                                        return qsTr("%1%2%3").arg(model.method).arg(model.implement ? ", " : "").arg(model.implement)
                                    }

                                }

                                elide: Text.ElideRight
                                width: tableHeaderModel[2].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: NDate.formatDate(model.assigned_date, year, "")
                                elide: Text.ElideRight
                                width: tableHeaderModel[3].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        Column {
                            id: detailsRow
                            visible: detailsButton.checked
                            width: parent.width
                            height: detailsButton.checked ? (idList.length - 1) * Units.rowHeight : 0
                            Repeater {
                                model: idList.slice(1)

                                Row {
                                    height: Units.rowHeight
                                    spacing: Units.smallSpacing
                                    leftPadding: Units.smallSpacing
                                    Item { width: parent.height; height: width }
                                    PlantingLabel {
                                        plantingId: Number(modelData)
                                        year: page.year
                                        sowingDate: Planting.sowingDate(plantingId)
                                        endHarvestDate: Planting.endHarvestDate(plantingId)
                                        showOnlyDates: true
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
