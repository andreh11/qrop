/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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
import Qt.labs.calendar 1.0

import io.qrop.components 1.0


Page {
    id: page

    property alias week: yearSpinBox.week
    property alias year: yearSpinBox.year
    property alias rowsNumber: recordModel.rowCount
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0
    property alias listView: recordView
    property date todayDate: new Date()

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"
    property var tableHeaderModel: [
        { name: qsTr("Date"),    columnName: "date", width: 100},
        { name: qsTr("Type"),   columnName: "type", width: 100 },
        { name: qsTr("Details"),   columnName: "details", width: 300 },
        { name: qsTr("Plantings"),   columnName: "plantings", width: 200 },
        { name: qsTr("Locations"), columnName: "locations", width: 200 },
    ]

    property int rowWidth: {
        var width = 0;
        for (var i = 0; i < tableHeaderModel.length; i++)
            width += tableHeaderModel[i].width + Units.formSpacing
        return width;
    }

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = recordView.contentY
        recordModel.refresh();
        recordView.contentY = currentY
    }

    title: qsTr("Harvests")
    focus: true
    padding: 0

    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: tableSortOrder = "descending"

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 3 && addButton.visible && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 3 && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 3 && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: yearSpinBox.nextWeek()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 3 && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: yearSpinBox.previousWeek()
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 3 && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: yearSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 3 && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: yearSpinBox.previousYear();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 3 && !recordView.activeFocus && !harvestDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: {
            recordView.currentIndex = 0
            recordView.forceActiveFocus();
        }
    }

    Snackbar {
        id: addHarvestSnackbar
        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Harvest added")
        visible: false
    }

    Snackbar {
        id: editHarvestsSnackBar
        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Harvest modified")
        visible: false
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
            height: Units.toolBarHeight

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: Units.smallSpacing
                visible: !filterMode

                Label {
                    text: qsTr("%L1 harvest(s) selected", "", checks).arg(checks)
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
                    text: qsTr("Add note")
                    flat: true
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    Material.foreground: Material.accent
                    font.pixelSize: Units.fontSizeBodyAndButton
                    visible: checks === 0
                    onClicked: harvestDialog.create()

                    MouseArea {
                        id: mouseArea
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onPressed: mouse.accepted = false
                    }

                    HarvestDialog {
                        id: harvestDialog
                        y: parent.height * 2/3
                        year: page.year
                        onHarvestAdded: {
                            page.refresh()
                            addHarvestSnackbar.open();
                        }
                        onHarvestUpdated: {
                            page.refresh();
                            editHarvestsSnackBar.open();
                        }
                    }
                }

                SearchField {
                    id: filterField
                    placeholderText: qsTr("Search records")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhPreferLowercase
                    visible: !checks
                }

                WeekSpinBox {
                    id: yearSpinBox
                    visible: checks === 0
                    week: MDate.currentWeek();
                    year: MDate.currentYear();
                    showOnlyYear: true
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
            id: recordView
            width: Math.max(rowWidth, parent.width * 0.8)
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalAndVerticalFlick

            anchors {
                top: topDivider.bottom
                bottom: parent.bottom

                horizontalCenter: parent.horizontalCenter
                topMargin: Units.smallSpacing
                bottomMargin: Units.smallSpacing
            }

            model: RecordModel {
                id: recordModel
                year: page.year
                filterString: filterField.text
                sortColumn: tableHeaderModel[tableSortColumn].columnName
                sortOrder: tableSortOrder
            }

            highlightMoveDuration: 0
            highlightResizeDuration: 0
            highlight: Rectangle {
                visible: recordView.activeFocus
                z:3;
                opacity: 0.1;
                color: Material.primary
                radius: 2
            }

            ScrollBar.vertical: ScrollBar {
                parent: recordView.parent
                anchors.top: recordView.top
                anchors.left: recordView.right
                anchors.bottom: recordView.bottom
            }

            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_E:
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    currentItem.editHarvest();
                    break;
                case Qt.Key_Delete:
                    currentItem.deleteHarvest();
                    break;
                }
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

//                        Item {
//                            visible: true
//                            id: headerCheckbox
//                            anchors.verticalCenter: headerRow.verticalCenter
//                            width: parent.height
//                            height: width
//                        }

                        Repeater {
                            model: page.tableHeaderModel

                            TableHeaderLabel {
                                text: modelData.name
                                anchors.verticalCenter: headerRow.verticalCenter
                                width: modelData.width
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                                onNewColumn: {
                                    if (page.tableSortColumn !== index) {
                                        page.tableSortColumn = index
                                        page.tableSortOrder = "descending"
                                    }
                                }
                                onNewOrder: page.tableSortOrder = order
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
                height: Units.rowHeight
                width: parent.width

                function editHarvest() {
                    harvestDialog.edit(model.harvest_id, model.crop_id);
                }

                function deleteHarvest() {
                    Harvest.remove(model.harvest_id);
                    page.refresh();
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    propagateComposedEvents: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: editHarvest()

                    Rectangle {
                        id: harvestButtonRectangle
                        height: Units.rowHeight
                        width: childrenRect.width
                        color: "white"
                        z: 3
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
                                id: deleteButton
                                text: enabled ? "\ue872" : ""
                                font.family: "Material Icons"
                                font.pixelSize: 22
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: deleteHarvest()
                                ToolTip.text: qsTr("Remove")
                                ToolTip.visible: hovered
                            }
                        }
                    }

                    Row {
                        id: summaryRow
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: Units.formSpacing

                        Label {
                            text: MDate.formatDate(model.date, year)
                            elide: Text.ElideRight
                            width: tableHeaderModel[0].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: {
                                if (model.type === "task")
                                    return qsTr("Task");
                                else if (model.type === "note")
                                    return qsTr("Note")
                                else if (model.type === "harvest")
                                    return qsTr("Harvest")
                                else
                                    return qsTr("Unknown");
                            }
                            elide: Text.ElideRight
                            width: tableHeaderModel[1].width
                            anchors.verticalCenter: parent.verticalCenter
                        }


                        Label {
                            text: model.details
                            elide: Text.ElideRight
                            width: tableHeaderModel[2].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        PlantingLabel {
                            year: page.year
                            anchors.verticalCenter: parent.verticalCenter
                            plantingId: model.plantings
                            showRank: true
                        }

                        Label {
                            text: Location.fullNameList(model.locations.split(","))
                            elide: Text.ElideRight
                            width: tableHeaderModel[2].width
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
