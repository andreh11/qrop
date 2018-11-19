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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
    id: page

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0

    property var tableHeaderModel: [
//        { name: qsTr("Task"),        columnName: "task",    width: 200},
        { name: qsTr("Plantings"),   columnName: "plantings", width: 200 },
        { name: qsTr("Locations"),   columnName: "locations", width: 200 },
        { name: qsTr("Description"), columnName: "descr", width: 200 },
        { name: qsTr("Due Date"),   columnName: "assigned_date", width: 80 }
    ]

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"

    function cropName(id) {
        var map = Planting.mapFromId("planting_view", id);
        return map['crop']
    }

    function varietyName(id) {
        var map = Planting.mapFromId("planting_view", id);
        return map['variety']
    }

    title: "Calendar"
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName
        tableSortOrder = "descending"
        listView.model.setSortColumn(columnName, tableSortOrder)
    }

    onTableSortOrderChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName
        listView.model.setSortColumn(columnName, tableSortOrder)
    }

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
        height: parent.height
        x: (parent.width - width) / 2
    }

    Component {
        id: sectionHeading
        Rectangle {
            width: parent.width
            height: Units.rowHeight * 1.2
//            color: Material.color(Material.Green, Material.Shade200)
            color: Material.color(Material.Grey, Material.Shade100)
            radius: 4

            anchors.topMargin: 2

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
                    onClicked: taskDialog.open()
                }

                SearchField {
                    id: filterField
                    placeholderText: qsTr("Search Tasks")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhPreferLowercase
                    visible: !checks && rowsNumber
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
                leftMargin: 80
                rightMargin: 80
//                leftMargin: Units.smallSpacing
//                rightMargin: leftMargin
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
//                sortColumn: "assigned_date"
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
                        leftPadding: 16

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
//                color: {
//                    if (checkBox.checked) {
//                        return Material.color(Material.primary, Material.Shade100)
//                    } else if (mouseArea.containsMouse) {
//                        return Material.color(Material.Grey, Material.Shade100)
//                    } else {
//                        return "white"
//                    }
//                }
                color: "white"
                radius: 4

                height: row.height
                width: parent.width

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Column {
                    id: mainColumn
                    width: parent.width

                    Row {
                        id: row
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: 16

                        ToolButton {
                            id: completeButton
//                            flat: true
                            checkable: true
                            width: parent.height
                            height: width
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.fill: parent
                                text: "\ue86c"
                                font.family: "Material Icons"
                                font.pixelSize: 30
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: parent.checked ? Material.color(Material.Green)
                                                      : Material.color(Material.Grey,
                                                                       Material.Shade300)
                            }
                        }

//                        TextCheckBox {
//                            id: checkBox
//                            text: model.type
//                            selectionMode: checks > 0
//                            anchors.verticalCenter: row.verticalCenter
//                            //                                width: 24
//                            width: parent.height * 0.8
//                            round: true
//                            color: "green"
////                            checked: model.planting_id in selectedIds
////                                     && selectedIds[model.planting_id]

////                            MouseArea {
////                                anchors.fill: parent
//////                                onClicked: {
//////                                    if (mouse.button !== Qt.LeftButton)
//////                                        return

//////                                    selectedIds[model.planting_id]
//////                                            = !selectedIds[model.planting_id]
//////                                    lastIndexClicked = index

//////                                    selectedIdsChanged()
//////                                    console.log("All:", plantingModel.rowCount( ) === checks)
//////                                }
////                            }
//                        }
                        TableLabel {
                            text: cropName(model.plantings) + " <i>" + varietyName(model.plantings) + "</i>"
                            elide: Text.ElideRight
                            width: tableHeaderModel[0].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TableLabel {
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

                        TableLabel {
                            text: {
                                var planting_ids = model.plantings.split(',')
                                var planting_id = Number(planting_ids[0])
                                var map = Planting.mapFromId("planting_view", planting_id);
                                if (task_type_id === 1 || task_type_id === 3) {
                                    return map["length"] + " m @ " + map['rows'] + " x " + map['spacing_plants'] + " cm"
                                } else if (task_type_id === 2) {
                                    return qsTr("%L1 trays of  %L2").arg(map["trays_to_start"]).arg(map['tray_size'])
                                }
                            }


                            elide: Text.ElideRight
                            width: tableHeaderModel[2].width
                            anchors.verticalCenter: parent.verticalCenter
                        }


                        TableLabel {
                            text: NDate.formatDate(model.assigned_date, year, "")
                            elide: Text.ElideRight
                            width: tableHeaderModel[3].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }
                }
            }
        }
    }
}
