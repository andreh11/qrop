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
    property string filterText: ""
    property int checks: 0
    property alias listView: harvestView
    property date todayDate: new Date()
    property bool dialogOpened: false
    property bool shortcutEnabled: navigationIndex === 3 && !dialogOpened

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

    function doPrint(file) {
        Print.printHarvests(page.year, file)
    }

    title: qsTr("Harvests")
    padding: 0

    Material.background: Material.color(Material.Grey, Material.Shade200)

    onTableSortColumnChanged: tableSortOrder = "descending"

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

            FlatButton {
                id: addButton
                text: qsTr("Add harvest")
                anchors {
                    left: parent.left
                    leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    verticalCenter: parent.verticalCenter
                }
                highlighted: true

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
                id: searchField
                placeholderText: qsTr("Search harvests")
                anchors {
                    centerIn: parent
                }
                width: Math.max(200, harvestView.width)
                inputMethodHints: Qt.ImhPreferLowercase
                visible: !checks
            }

            WeekSpinBox {
                id: weekSpinBox
                visible: checks === 0
                week: QrpDate.currentWeek();
                year: QrpDate.currentYear();
                anchors {
                    right: printButton.left
                    verticalCenter: parent.verticalCenter
                }
            }

            IconButton {
                id: printButton
                text: "\ue8ad"
                hoverEnabled: true
                anchors {
                    right: parent.right
                    rightMargin: 16 - padding
                    verticalCenter: parent.verticalCenter
                }
                ToolTip.visible: hovered
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.text: qsTr("Print the harvests list")

                onClicked: {
                    if (BuildInfo.isMobileDevice())
                        printHarvestsMobileDialog.open();
                    else
                        printHarvestsDialog.open();
                }
            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
            width: parent.width
        }

        Pane {
            Material.background: "white"
            width: Math.min(rowWidth, parent.width * 0.8)
            anchors {
                top: topDivider.bottom
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: Units.smallSpacing
                bottomMargin: Units.smallSpacing
            }
            padding: 0
            background: Rectangle {
                color: "white"
                border.color: Qt.rgba(0, 0, 0, 0.12) // From Material guidelines
                radius: 4
                border.width: 1
            }

            ListView {
                id: harvestView
                //            width: Math.min(rowWidth, parent.width * 0.8)
                anchors.fill: parent
                anchors.margins: 1
                clip: true
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalAndVerticalFlick

                model: HarvestModel {
                    id: harvestModel
                    week: page.week
                    year: page.year
                    filterString: searchField.text
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
                    anchors {
                        top: parent.top
                        topMargin: buttonRectangle.height + topDivider.height
                        right: parent.right
                        bottom: parent.bottom
                    }
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
                    color: "white"
                    radius: 4
                    z: 3
                    Column {
                        width: parent.width

                        Row {
                            id: headerRow
                            height: 56
                            spacing: Units.smallSpacing
                            leftPadding: Units.formSpacing

                            Item {
                                visible: true
                                id: headerCheckbox
                                anchors.verticalCenter: headerRow.verticalCenter
                                width: Units.rowHeight * 0.8
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
                        ThinDivider { width: parent.width }
                    }
                }

                delegate: Rectangle {
                    id: delegate
                    color: "white"
                    border.color: Material.color(Material.Grey, Material.Shade400)
                    border.width: rowMouseArea.containsMouse ? 1 : 0

                    radius: 2
                    height: 52
                    width: parent.width

                    property var map: Planting.mapFromId(model.planting_id)

                    function editHarvest() {
                        harvestDialog.edit(model.harvest_id, model.crop_id);
                        dialogOpened = true;
                    }

                    function deleteHarvest() {
                        Harvest.remove(model.harvest_id);
                        page.refresh();
                    }

                    ThinDivider {
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
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
                            anchors.verticalCenter: parent.verticalCenter

                            TextCheckBox {
                                id: plantingCheckBox
                                width: parent.height * 0.8
                                text: map['crop'].slice(0,2)
                                rank: map['planting_rank']
                                font.pixelSize: 26
                                color: map['crop_color']
                                round: true
                                anchors.verticalCenter: parent.verticalCenter
                                hoverEnabled: false
                                checkable: false
                            }

                            PlantingLabel {
                                width: tableHeaderModel[0].width
                                anchors.verticalCenter: parent.verticalCenter
                                plantingId: model.planting_id
                                showOnlyDates: true
                                year: page.year
                                showRank: false
                            }

                            TableLabel {
                                text: Location.fullNameList(Location.locations(model.planting_id))
                                width: tableHeaderModel[1].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TableLabel {
                                text: "%L1 %2".arg(Math.round(model.quantity * 100) /100).arg(model.unit)
                                width: tableHeaderModel[2].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TableLabel {
                                text: QrpDate.dayName(model.date)
                                width: tableHeaderModel[3].width
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TableLabel {
                                text: model.time
                                width: tableHeaderModel[4].width
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // Dialogs

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
        id: printHarvestsDialog
        defaultSuffix: "pdf"
        folder: Qt.resolvedUrl(window.lastFolder)
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: doPrint(file);
    }

    MobileFileDialog {
        id: printHarvestsMobileDialog

        title : qsTr("Print the harvests list")
        text : qsTr("Please type a name for the PDF.")
        acceptText: qsTr("Print")

        x: page.width - width
        y: buttonRectangle.height

        nameField.visible : true;
        combo.visible : false;

        onAccepted: {
            //MB_TODO: check if the file already exist? shall we overwrite or discard?
            doPrint('file://%1/%2.pdf'.arg(FileSystem.pdfPath).arg(nameField.text));
        }
    }

    // Shortcuts

    ApplicationShortcut {
        sequences: ["Ctrl+N"]; enabled: shortcutEnabled; onActivated: addButton.clicked()
    }

    ApplicationShortcut {
        sequences: [StandardKey.Find]; enabled: shortcutEnabled; onActivated: searchField.forceActiveFocus();
    }

    ApplicationShortcut {
        sequence: "Ctrl+Right"; enabled: shortcutEnabled; onActivated: weekSpinBox.nextWeek()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Left"; enabled: shortcutEnabled; onActivated: weekSpinBox.previousWeek()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Up"; enabled: shortcutEnabled; onActivated: weekSpinBox.nextYear()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Down"; enabled: shortcutEnabled; onActivated: weekSpinBox.previousYear();
    }

    ApplicationShortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: shortcutEnabled && !harvestView.activeFocus
        onActivated: {
            harvestView.currentIndex = 0
            harvestView.forceActiveFocus();
        }
    }
}
