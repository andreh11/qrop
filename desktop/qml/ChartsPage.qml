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

import QtCharts 2.2

import io.qrop.components 1.0

Page {
    id: page
    padding: 0
    title: qsTr("Charts")

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year

    function refresh() {
        cropDistributionChart.refresh();
        cropRevenueChart.refresh();
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

            Row {
                id: checkButtonRow
                spacing: 0

                ButtonCheckBox {
                    id: fieldCheckBox
                    checked: true
                    text: qsTr("Field")
                    autoExclusive: true
                    onCheckedChanged: refresh();
                }

                ButtonCheckBox {
                    id: greenhouseCheckBox
                    text: qsTr("Greenhouse")
                    autoExclusive: true
                }

                Layout.leftMargin: 16
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

    GridLayout {
        id: gridLayout
        columns: 2
        columnSpacing: Units.mediumSpacing
        rowSpacing: columnSpacing

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
                Layout.preferredHeight: 80
                Layout.preferredWidth: 200
            }

            StatCard {
                title: qsTr("Number of beds")
                text: "%L1".arg(Helpers.bedLength(Planting.totalLengthForYear(page.year, greenhouseCheckBox.checked)))

//                Material.background: Material.color(Material.Orange, Material.Shade400)
                Material.background: "white"
                Layout.preferredHeight: 80
                Layout.preferredWidth: 200
            }

            StatCard {
                title: qsTr("Number of crops")
                text: "%L1".arg(cropDistributionChart.numberOfCrops)

//                Material.background: Material.color(Material.Pink, Material.Shade400)
                Material.background: "white"
                Layout.preferredHeight: 80
                Layout.preferredWidth: 200
            }
        }

        Pane {
            id: cardPane
            Material.elevation: 1
            Material.background: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true

            Row {
                z: 2
                spacing: 0
                anchors {
                    top: parent.top
                    right: parent.right
                }

                ButtonCheckBox {
                    id: spaceCheckBox
                    text: qsTr("Space")
                    autoExclusive: true
                    checked: true
                }

                ButtonCheckBox {
                    id: revenueCheckBox
                    text: qsTr("Revenue")
                    autoExclusive: true
                    onCheckedChanged: refresh();
                }
            }

            DistributionChart {
                id: cropDistributionChart
                visible: spaceCheckBox.checked
                anchors.fill: parent
                year: page.year
                greenhouse: greenhouseCheckBox.checked
            }

            CropRevenueChart {
                id: cropRevenueChart
                visible: revenueCheckBox.checked
                anchors.fill: parent
                year: page.year
                greenhouse: greenhouseCheckBox.checked
            }
        }

        Pane {
            visible: false
            Material.elevation: 1
            Material.background: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
