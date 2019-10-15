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

//import QtCharts 2.2

import io.qrop.components 1.0

Page {
    id: page
    padding: 0
    title: qsTr("Charts")

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year

    property int tableSortColumn: 0
    property string tableSortOrder: "ascending"
    property var tableHeaderModel: [
        { name: qsTr("Crop"),
            columnName: "crop",
            width: 150,
            alignment: Text.AlignLeft,
            visible: true },
        { name: qsTr("Varieties"),
            columnName: "variety_number",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Total length"),
            columnName: "total_length",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Total yield"),
            columnName: "total_yield",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Total Revenue"),
            columnName: "total_revenue",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Field length"),
            columnName: "field_length",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Field yield"),
            columnName: "field_yield",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Field Revenue"),
            columnName: "field_revenue",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Greenhouse length"),
            columnName: "greenhouse_length",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Greenhouse yield"),
            columnName: "greenhouse_yield",
            width: 80,
            alignment: Text.AlignRight,
            visible: true },
        { name: qsTr("Greenhouse Revenue"),
            columnName: "greenhouse_revenue",
            width: 80,
            alignment: Text.AlignRight,
            visible: true }
    ]

    property int rowWidth: {
        var width = 0;
        for (var i = 0; i < tableHeaderModel.length; i++) {
            if (tableHeaderModel[i].visible)
                width += tableHeaderModel[i].width + Units.formSpacing
        }
        return width;
    }

    onTableSortColumnChanged: tableSortOrder = "descending"

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = cropStatView.contentY
        cropStatModel.refresh();
        cropStatView.contentY = currentY
    }
    //    function refresh() {
    ////        cropDistributionChart.refresh();
    ////        cropRevenueChart.refresh();
    //    }

    CropStatModel {
        id: cropStatModel
        year: page.year
        filterString: filterField.text
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    Rectangle {
        id: buttonRectangle
        color: "white"
        width: parent.width
        height: Units.toolBarHeight
        anchors { left: parent.left; right: parent.right; top: parent.top }

        RowLayout {
            id: buttonRow
            anchors.fill: parent
            spacing: Units.smallSpacing

            //            Row {
            //                id: checkButtonRow
            //                spacing: 0

            //                ButtonCheckBox {
            //                    id: fieldCheckBox
            //                    checked: true
            //                    text: qsTr("Field")
            //                    autoExclusive: true
            //                    onCheckedChanged: refresh();
            //                }

            //                ButtonCheckBox {
            //                    id: greenhouseCheckBox
            //                    text: qsTr("Greenhouse")
            //                    autoExclusive: true
            //                }

            //                Layout.leftMargin: 16
            //            }
            SearchField {
                id: filterField
                placeholderText: qsTr("Search...")
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferLowercase
                Layout.leftMargin: Units.mediumSpacing

            }

            Item {
                Layout.fillWidth: true
            }

            WeekSpinBox {
                id: weekSpinBox
                visible: true
                week: MDate.currentWeek();
                year: MDate.currentYear();
                showOnlyYear: true
                Layout.rightMargin: 16
            }
        }
    }

    ThinDivider {
        id: topDivider
        anchors.top: buttonRectangle.bottom
        width: parent.width
    }

    RowLayout {
        id: gridLayout
        spacing: Units.mediumSpacing

        anchors {
            top: topDivider.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Units.mediumSpacing
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: Units.mediumSpacing

            StatCard {
                title: qsTr("Estimated revenue")
                text: qsTr("$%L1").arg(Planting.revenue(page.year))

                //                Material.background: Material.color(Material.Green, Material.Shade400)
                Material.background: "white"
                Layout.preferredHeight: 100
                Layout.preferredWidth: 200
            }

            StatCard {
                title: qsTr("Number of beds")
                subtitle: qsTr("Field")
                text: "%L1".arg(Helpers.bedLength(Planting.totalLengthForYear(page.year, false)))

                Material.background: "white"
                Layout.preferredHeight: 100
                Layout.preferredWidth: 200
            }

            StatCard {
                title: qsTr("Number of beds")
                subtitle: qsTr("Greenhouse")
                text: "%L1".arg(Helpers.bedLength(Planting.totalLengthForYear(page.year, true)))

                Material.background: "white"
                Layout.preferredHeight: 100
                Layout.preferredWidth: 200
            }

            StatCard {
                title: qsTr("Number of crops")
                text: "%L1".arg(cropStatModel.rowCount)

                //                Material.background: Material.color(Material.Pink, Material.Shade400)
                Material.background: "white"
                Layout.preferredHeight: 100
                Layout.preferredWidth: 200
            }
        }

        Pane {
            id: cardPane
            Material.elevation: 1
            Material.background: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0

            ListView {
                id: cropStatView
                clip: true
                spacing: 0
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalAndVerticalFlick
                contentWidth: contentItem.childrenRect.width
//                height: parent.height
//                width: parent.width

                anchors.fill: parent
                anchors.margins: 1

                model: cropStatModel
                //                highlightMoveDuration: 0
                //                highlightResizeDuration: 0
                //                highlight: Rectangle {
                //                    visible: cropStatView.activeFocus
                //                    z:3;
                //                    opacity: 0.1;
                //                    color: Material.primary
                //                    radius: 2
                //                }

                //                ScrollBar.vertical: ScrollBar {
                //                    parent: cropStatView.parent
                //                    anchors {
                //                        top: parent.top
                //                        topMargin: buttonRectangle.height + topDivider.height
                //                        right: parent.right
                //                        bottom: parent.bottom
                //                    }
                //                }

                ScrollBar.vertical: ScrollBar {}
                ScrollBar.horizontal: ScrollBar {}

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
                        model.crop,
                        "%L1".arg(model.variety_number),
                        "%L1".arg(Helpers.bedLength(model.total_length)),
                        "%L1".arg(model.total_yield),
                        "%L1 €".arg(model.total_revenue),
                        "%L1".arg(Helpers.bedLength(model.field_length)),
                        "%L1".arg(model.field_yield),
                        "%L1 €".arg(model.field_revenue),
                        "%L1".arg(Helpers.bedLength(model.greenhouse_length)),
                        "%L1".arg(model.greenhouse_yield),
                        "%L1 €".arg(model.greenhouse_revenue)
                    ]

                    color: rowMouseArea.containsMouse
                           ? Material.color(Material.Grey, Material.Shade100)
                           : "white"
                    radius: 2
                    height: Units.tableRowHeight
                    width: summaryRow.width

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

            //            Row {
            //                z: 2
            //                spacing: 0
            //                anchors {
            //                    top: parent.top
            //                    right: parent.right
            //                }

            //                ButtonCheckBox {
            //                    id: spaceCheckBox
            //                    text: qsTr("Space")
            //                    autoExclusive: true
            //                    checked: true
            //                }

            //                ButtonCheckBox {
            //                    id: revenueCheckBox
            //                    text: qsTr("Revenue")
            //                    autoExclusive: true
            //                    onCheckedChanged: refresh();
            //                }
            //            }

            //            ScrollView {
            //                anchors.fill: parent
            //                clip: true


            //                contentHeight: height * 2

            //                DistributionChart {
            //                    id: cropDistributionChart
            //                    visible: spaceCheckBox.checked
            //                    height: parent.height * 2
            //                    width: parent.width
            //                    year: page.year
            //                    greenhouse: greenhouseCheckBox.checked
            //                }

            //                CropRevenueChart {
            //                    id: cropRevenueChart
            //                    width: parent.width
            //                    height: parent.height * 2
            //                    visible: revenueCheckBox.checked
            //                    year: page.year
            //                    greenhouse: greenhouseCheckBox.checked
            //                }
            //            }

            //        Pane {
            //            visible: false
            //            Material.elevation: 1
            //            Material.background: "white"
            //            Layout.fillWidth: true
            //            Layout.fillHeight: true
            //        }
        }
    }
}
