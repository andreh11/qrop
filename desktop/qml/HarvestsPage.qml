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
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Page {
    id: page

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year
    property alias rowCount: harvestModel.rowCount
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0
    property alias listView: harvestView
    property date todayDate: new Date()
    property bool dialogOpened: false

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"
    property var tableHeaderModel: [
        { name: qsTr("Planting"),   columnName: "planting_id", width: 200 },
        { name: qsTr("Locations"),  columnName: "locations",   width: 200 },
        { name: qsTr("Quantity"),   columnName: "quantity",    width: 80 },
        { name: qsTr("Date"),       columnName: "date",        width: 100},
        { name: qsTr("Time"),       columnName: "time",        width: 80}
    ]

    property int rowWidth: {
        var width = 0;
        for (var i = 0; i < tableHeaderModel.length; i++)
            width += tableHeaderModel[i].width + Units.formSpacing
        return width;
    }

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and the view's position will be reset.
        var currentY = harvestView.contentY
        harvestModel.refresh();
        harvestView.contentY = currentY
    }

    title: qsTr("Harvests")
    padding: 0

    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: tableSortOrder = "descending"

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextWeek()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousWeek()
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 3 && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousYear();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 3 && !harvestView.activeFocus && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: {
            harvestView.currentIndex = 0
            harvestView.forceActiveFocus();
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

    Platform.FileDialog {
        id: saveDialog
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        defaultSuffix: "pdf"
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: Print.printHarvests(page.year, file)
    }

    Pane {
        anchors.fill: parent
        padding: 0

        Column {
            id: blankStateColumn
            z: 1
            spacing: Units.smallSpacing
            visible: !page.rowCount
            anchors {
                centerIn: parent
            }

            Label {
                id: emptyStateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr('No harvests for week %1').arg(page.week)
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
                onClicked: addButton.clicked()
            }
        }

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

                //                Label {
                //                    text: qsTr("%L1 harvest(s) selected", "", checks).arg(checks)
                //                    leftPadding: 16
                //                    color: Material.color(Material.Blue)
                //                    Layout.fillWidth: true
                //                    visible: checks > 0
                //                    font.family: "Roboto Regular"
                //                    font.pixelSize: 16
                //                    horizontalAlignment: Qt.AlignLeft
                //                    verticalAlignment: Qt.AlignVCenter
                //                }

                Button {
                    id: addButton
                    text: qsTr("Add harvest")
                    flat: true
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    highlighted: true
                    font.pixelSize: Units.fontSizeBodyAndButton

                    onClicked: {
                        dialogOpened = true;
                        harvestDialog.create()
                    }

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
                            dialogOpened = false;
                        }
                        onHarvestUpdated: {
                            page.refresh();
                            editHarvestsSnackBar.open();
                            dialogOpened = false;
                        }
                        onRejected: dialogOpened = false;
                    }
                }

                SearchField {
                    id: filterField
                    placeholderText: qsTr("Search harvests")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhPreferLowercase
                    visible: !checks
                }

                WeekSpinBox {
                    id: weekSpinBox
                    visible: checks === 0
                    week: MDate.currentWeek();
                    year: MDate.currentYear();
                }

                IconButton {
                    id: printButton
                    text: "\ue8ad"
                    hoverEnabled: true

                    Layout.rightMargin: 16 - padding
                    ToolTip.visible: hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: qsTr("Print the harvests list")

                    onClicked: saveDialog.open()
                }

            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
            width: parent.width
        }

        ListView {
            id: harvestView
            width: Math.min(rowWidth, parent.width * 0.8)
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

            model: HarvestModel {
                id: harvestModel
                week: page.week
                year: page.year
                filterString: filterField.text
                sortColumn: tableHeaderModel[tableSortColumn].columnName
                sortOrder: tableSortOrder
            }

            highlightMoveDuration: 0
            highlightResizeDuration: 0
            highlight: Rectangle {
                visible: harvestView.activeFocus
                z:3;
                opacity: 0.1;
                color: Material.primary
                radius: 2
            }

            ScrollBar.vertical: ScrollBar {
                parent: harvestView.parent
                anchors.top: harvestView.top
                anchors.left: harvestView.right
                anchors.bottom: harvestView.bottom
            }

            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_E:
                    // FALLTHROUGH
                case Qt.Key_Return:
                    // FALLTHROUGH
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
                    dialogOpened = true;
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

                        Rectangle {
                            id: textIcon
                            height: parent.height * 0.8
                            //            height: 40
                            width: height
                            radius: 80
                            color: Planting.cropColor(model.planting_id)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: Planting.cropName(model.planting_id).slice(0,2)
                                color: "white"
                                font { family: "Roboto Regular"; pixelSize: 20 }
                            }
                        }

                        PlantingLabel {
                            width: tableHeaderModel[0].width
                            anchors.verticalCenter: parent.verticalCenter
                            plantingId: model.planting_id
                            showOnlyDates: true
                            sowingDate: Planting.sowingDate(plantingId)
                            endHarvestDate: Planting.endHarvestDate(plantingId)
                            year: page.year
                        }

                        Label {
                            text: Location.fullName(Location.locations(model.planting_id))
                            elide: Text.ElideRight
                            width: tableHeaderModel[1].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: "%L1 %2".arg(Math.round(model.quantity)).arg(model.unit)
                            elide: Text.ElideRight
                            width: tableHeaderModel[2].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: MDate.dayName(model.date)
                            elide: Text.ElideRight
                            width: tableHeaderModel[3].width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.time
                            elide: Text.ElideRight
                            width: tableHeaderModel[4].width
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
