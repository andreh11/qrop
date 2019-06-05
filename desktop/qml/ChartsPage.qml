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

            Item {
                Layout.fillWidth: true
            }

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

        Pane {
            id: cardPane
            Material.elevation: 1
            Material.background: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true

            DistributionChart {
                id: cropDistributionChart
                anchors.fill: parent
                year: page.year
                greenhouse: greenhouseCheckBox.checked
            }
        }

        Pane {
            Material.elevation: 1
            Material.background: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true
            CropRevenueChart {
                id: cropRevenueChart
                anchors.fill: parent
                year: page.year
                greenhouse: greenhouseCheckBox.checked
            }
        }
    }
}
