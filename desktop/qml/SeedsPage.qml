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
    property alias seedsRowCount: seedListModel.rowCount
    property alias transplantsRowCount: transplantListModel.rowCount
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0
    property alias listView: seedListView
    property date todayDate: new Date()

    property int tableSortColumn: 1
    property string tableSortOrder: "ascending"
    property var tableHeaderModel: [
        { name: qsTr("Date"),   columnName: "planting_date", width: 100, alignment: Text.AlignLeft, visible: transplantsRadioButton.checked },
        { name: qsTr("Crop"),   columnName: "crop", width: 200, alignment: Text.AlignLeft, visible: true },
        { name: qsTr("Variety"),   columnName: "variety", width: 200, alignment: Text.AlignLeft, visible: true },
        { name: qsTr("Seed company"), columnName: "seed_company", width: 200, alignment: Text.AlignLeft, visible: true },
        { name: qsTr("Number"),    columnName: seedsRadioButton.checked ? "seeds_number" : "plants_needed", width: 100, alignment: Text.AlignRight, visible: true },
        { name: qsTr("Quantity"),    columnName: "seeds_quantity", width: 100, alignment: Text.AlignRight,
            visible: seedsRadioButton.checked }
    ]

    property int rowWidth: {
        var width = 0;
        for (var i = 0; i < tableHeaderModel.length; i++) {
            if (tableHeaderModel[i].visible)
                width += tableHeaderModel[i].width + Units.formSpacing
        }
        return width;
    }

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = seedListView.contentY
        seedListModel.refresh();
        transplantListModel.refresh();
        seedListView.contentY = currentY
    }

    title: qsTr("Seed & transplant lists")
    focus: true
    padding: 0

    Material.background: Material.color(Material.Grey, Material.Shade100)

    onTableSortColumnChanged: tableSortOrder = "descending"

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 4
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 4
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 4
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousYear();
    }

    //    Shortcut {
    //        sequences: ["Up", "Down", "Left", "Right"]
    //        enabled: navigationIndex === 4
    //        context: Qt.ApplicationShortcut
    //        onActivated: {
    //            seedListView.currentIndex = 0
    //            seedListView.forceActiveFocus();
    //        }
    //    }

    SeedListModel {
        id: seedListModel
        year: page.year
        filterString: filterField.text
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    TransplantListModel {
        id: transplantListModel
        year: page.year
        filterString: filterField.text
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    Platform.FileDialog {
        id: saveDialog

        defaultSuffix: "pdf"
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: {
            if (seedsRadioButton.checked)
                Print.printSeedList(page.year, file);
            else
                Print.printTransplantList(page.year, file);
        }
    }

    Pane {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        padding: 0
        Material.elevation: 1

        Label {
            id: seedBlankLabel
            anchors.centerIn: parent
            visible: seedsRadioButton.checked && !seedsRowCount
            text:  qsTr('No seeds to order for %1').arg(page.year)
            font { family: "Roboto Regular"; pixelSize: Units.fontSizeTitle }
            color: Qt.rgba(0, 0, 0, 0.8)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: transplantBlankLabel
            anchors.centerIn: parent
            visible: transplantsRadioButton.checked && !transplantsRowCount
            text:  qsTr('No transplants to order for %1').arg(page.year)
            font { family: "Roboto Regular"; pixelSize: Units.fontSizeTitle }
            color: Qt.rgba(0, 0, 0, 0.8)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: buttonRectangle
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: Units.toolBarHeight

            //            RowLayout {
            //                id: buttonRow
            //                anchors.fill: parent
            //                spacing: Units.smallSpacing
            //                visible: !filterMode

            ButtonGroup {
                buttons: checkButtonRow.children
            }

            Row {
                id: checkButtonRow
                anchors {
                    left: parent.left
                    leftMargin: 16 - padding
                    verticalCenter: parent.verticalCenter
                }

                ButtonCheckBox {
                    id: seedsRadioButton
                    checked: true
                    text: qsTr("Seeds")
                }

                ButtonCheckBox {
                    id: transplantsRadioButton
                    text: qsTr("Transplants")
                }
            }

            SearchField {
                id: filterField
                placeholderText: seedsRadioButton.checked ? qsTr("Search seeds")
                                                          : qsTr("Search transplants")
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferLowercase
                width: seedListView.width

                anchors {
                    centerIn: parent
                }
            }

            WeekSpinBox {
                id: weekSpinBox
                showOnlyYear: true
                visible: checks === 0
                week: MDate.currentWeek();
                year: MDate.currentYear();
                anchors {
                    right: printButton.left
                    verticalCenter: parent.verticalCenter
                }
            }

            IconButton {
                id: printButton
                text: "\ue8ad"
                hoverEnabled: true

                Layout.rightMargin: 16 - padding
                ToolTip.visible: hovered
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.text: seedsRadioButton.checked ? qsTr("Print the seed order list")
                                                       : qsTr("Print the transplant order list")

                onClicked: saveDialog.open()

                anchors {
                    right: parent.right
                    rightMargin: 16 - padding
                    verticalCenter: parent.verticalCenter
                }

            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
            width: parent.width
        }

        ListView {
            id: seedListView
            width: rowWidth
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

            model: seedsRadioButton.checked ? seedListModel : transplantListModel
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            highlight: Rectangle {
                visible: seedListView.activeFocus
                z:3;
                opacity: 0.1;
                color: Material.primary
                radius: 2
            }

            ScrollBar.vertical: ScrollBar {
                parent: seedListView.parent
                anchors {
                    top: parent.top
                    topMargin: buttonRectangle.height + topDivider.height
                    right: parent.right
                    bottom: parent.bottom
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
                        leftPadding: Units.formSpacing

                        Repeater {
                            model: page.tableHeaderModel

                            TableHeaderLabel {
                                visible: (index == 0 && transplantsRadioButton.checked) || (index === 5 && seedsRadioButton.checked) || (index > 0 && index < 5)

                                text: modelData.name
                                anchors.verticalCenter: headerRow.verticalCenter
                                width: modelData.width
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                                horizontalAlignment: modelData.alignment
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

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    propagateComposedEvents: true
                    //                    cursorShape: Qt.PointingHandCursor

                    Row {
                        id: summaryRow
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: Units.formSpacing

                        Label {
                            visible: tableHeaderModel[0].visible
                            text: MDate.formatDate(model.planting_date, page.year)
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[0].width
                            horizontalAlignment: tableHeaderModel[0].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.crop
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[1].width
                            horizontalAlignment: tableHeaderModel[1].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.variety
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[2].width
                            horizontalAlignment: tableHeaderModel[2].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.seed_company
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[3].width
                            horizontalAlignment: tableHeaderModel[3].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: "%L1".arg(seedsRadioButton.checked ? model.seeds_number
                                                                     : model.plants_needed)
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[4].width
                            horizontalAlignment: tableHeaderModel[4].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            visible: tableHeaderModel[5].visible
                            text: model.seeds_quantity > 1000
                                  ? qsTr("%L1 kg").arg(Math.round(model.seeds_quantity * 0.1) / 100)
                                  : qsTr("%L1 g").arg(Math.round(model.seeds_quantity * 100) / 100)
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            elide: Text.ElideRight
                            width: tableHeaderModel[5].width
                            horizontalAlignment: tableHeaderModel[5].alignment
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
