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
        { name: qsTr("Date"),
            columnName: "planting_date",
            width: 100,
            alignment: Text.AlignLeft,
            visible: transplantsRadioButton.checked },
        { name: qsTr("Crop"),
            columnName: "crop",
            width: 150,
            alignment: Text.AlignLeft,
            visible: true },
        { name: qsTr("Variety"),
            columnName: "variety",
            width: 150,
            alignment: Text.AlignLeft,
            visible: true },
        { name: qsTr("Seed company"),
            columnName: "seed_company",
            width: 150,
            alignment: Text.AlignLeft,
            visible: true },
        { name: qsTr("Number"),
            columnName: seedsRadioButton.checked ? "seeds_number" : "plants_needed",
            width: 100,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Quantity"),
            columnName: "seeds_quantity",
            width: 100,
            alignment: Text.AlignRight,
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

    Material.background: Units.pageColor

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

    SeedListMonthModel {
        id: seedListMonthModel
        year: page.year
        filterString: filterField.text
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    SeedListQuarterModel {
        id: seedListQuarterModel
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
                Print.printSeedList(page.year, file, monthRangeButton.checked
                                    ? "month" : (quarterRangeButton.checked ? "quarter" : ""));
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

        BlankLabel {
            id: seedBlankLabel
            z:2
            primaryText: qsTr('No seeds to order for %1').arg(page.year)
            anchors.centerIn: parent
            visible: seedsRadioButton.checked && !seedsRowCount
        }

        BlankLabel {
            id: transplantBlankLabel
            z: 2
            primaryText: qsTr('No transplants to order for %1').arg(page.year)
            anchors.centerIn: parent
            visible: transplantsRadioButton.checked && !transplantsRowCount
        }

        Rectangle {
            id: buttonRectangle
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: Units.toolBarHeight

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
                //                width: seedListView.width

                anchors {
                    left: checkButtonRow.right
                    right: rangeButtonRow.left
                    leftMargin: Units.formSpacing
                    rightMargin: Units.formSpacing
                }
            }

            ButtonGroup {
                buttons: rangeButtonRow.children
            }

            Row {
                id: rangeButtonRow
                visible: seedsRadioButton.checked
                anchors {
                    right: weekSpinBox.left
                    rightMargin: Units.formSpacing
                    verticalCenter: parent.verticalCenter
                }

                ButtonCheckBox {
                    id: yearRangeButton
                    checked: true
                    text: qsTr("Year")
                }

                ButtonCheckBox {
                    id: quarterRangeButton
                    text: qsTr("Quarter")
                }

                ButtonCheckBox {
                    id: monthRangeButton
                    text: qsTr("Month")
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
                id: seedListView
                width: rowWidth
                clip: true
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds
//                contentWidth: contentItem.childrenRect.width
                flickableDirection: Flickable.HorizontalAndVerticalFlick

                anchors.fill: parent
                anchors.margins: 1

                model: {
                    if (seedsRadioButton.checked) {
                        if (yearRangeButton.checked)
                            seedListModel;
                        else if (quarterRangeButton.checked)
                            seedListQuarterModel;
                        else
                            seedListMonthModel;
                    } else {
                        transplantListModel
                    }
                }

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

                Component {
                    id: sectionHeading
                    Rectangle {
                        width: parent.width
                        height: Units.tableRowHeight
                        color: Material.color(Material.Grey, Material.Shade100)

                        Text {
                            text: (seedsRadioButton.checked && monthRangeButton.checked)
                                  ? Qt.locale().monthName(Number(section) - 1, Locale.LongFormat)
                                  : section
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: Units.formSpacing
                            color: Material.accent
                            font.bold: true
                            font.pixelSize: Units.fontSizeSubheading
                            font.family: "Roboto Regular"
                            font.capitalization: Font.Capitalize
                        }

                        ThinDivider {
                            anchors {
                                bottom: parent.bottom
                                left: parent.left
                                right: parent.right
                            }
                        }
                    }
                }

                section.criteria: ViewSection.FullString
                section.labelPositioning: ViewSection.CurrentLabelAtStart |  ViewSection.InlineLabels
                section.property: {
                    if (seedsRadioButton.checked) {
                        if (yearRangeButton.checked)
                            undefined;
                        else if (quarterRangeButton.checked)
                            "trimester";
                        else
                            "month";
                    } else {
                        "week";
                    }
                }
                section.delegate: {
                    if (seedsRadioButton.checked) {
                        if (yearRangeButton.checked)
                            null
                        else
                            sectionHeading
                    } else {
                        null
                    }
                }

                headerPositioning: ListView.OverlayHeader
                header: Rectangle {
                    id: headerRectangle
                    height: headerRow.height
                    width: parent.width
                    radius: 4

                    z: 3
                    Column {
                        width: parent.width

                        Row {
                            id: headerRow
                            height: Units.tableHeaderHeight
                            spacing: Units.smallSpacing
                            leftPadding: Units.formSpacing

                            Repeater {
                                model: page.tableHeaderModel

                                TableHeaderLabel {
                                    visible: (index == 0 && transplantsRadioButton.checked)
                                             || (index === 5 && seedsRadioButton.checked)
                                             || (index > 0 && index < 5)

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
                        ThinDivider { width: parent.width }
                    }
                }

                delegate: Rectangle {
                    id: delegate

                    property var labelList: [
                        MDate.formatDate(model.planting_date, page.year),
                        model.crop,
                        model.variety,
                        model.seed_company,
                        "%L1".arg(seedsRadioButton.checked ? model.seeds_number : model.plants_needed),
                        isFinite(model.seeds_quantity)
                        ? (model.seeds_quantity >= 1000
                        ? qsTr("%L1 kg").arg(Math.ceil(model.seeds_quantity / 10) / 100)
                        : qsTr("%L1 g").arg(Math.ceil(model.seeds_quantity * 10) / 10))
                        : "−"
                    ]

                    color: rowMouseArea.containsMouse
                           ? Material.color(Material.Grey, Material.Shade100)
                           : "white"
                    radius: 2
                    height: Units.tableRowHeight
                    width: parent.width

                    MouseArea {
                        id: rowMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Row {
                        id: summaryRow
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: Units.formSpacing
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: labelList
                            TableLabel {
                                text: modelData
                                visible: tableHeaderModel[index].visible
                                width: tableHeaderModel[index].width
                                horizontalAlignment: tableHeaderModel[index].alignment
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    ThinDivider {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    }
                }
            }
        }
    }
}
