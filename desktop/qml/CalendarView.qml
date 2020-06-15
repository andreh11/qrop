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

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0

import io.qrop.components 1.0

Item {
    id: control

    property date date: new Date()
    property int month
    property int year
    property bool dateSelected: false
    property bool mobileMode: false

    // Own signal emitted to preserve date binding.
    signal dateSelect(date newDate)

    width: gridLayout.width + 24
    height: dayBox.height + buttonLayout.height + gridLayout.height + 16

    function resetBindings() {
        month = date.getMonth();
        year = date.getFullYear();
    }

    function sameDates(date1, date2) {
        return (date1.getDate() === date2.getDate())
                && (date1.getMonth() === date2.getMonth())
                && (date1.getFullYear() === date2.getFullYear());
    }

    function goBackward() {
        if (month == 0) {
            month = 11;
            year = year - 1;
        } else {
            month--;
        }
    }

    function goForward() {
        if (month == 11) {
            month = 0;
            year = year + 1;
        } else {
            month++;
        }
    }

    function firstOfMonth(month) {
        var date = new Date(2018, month, 1)
        return date;
    }

    Column {
        id: mainColumn
        anchors.fill: parent
        height: childrenRect.height

        Rectangle {
            id: dayBox
            width: parent.width
            height: visible ? childrenRect.height : 0
            color: Material.primary
            visible: !largeDisplay

            Column {
                spacing: 0
                topPadding: 16
                bottomPadding: topPadding
                leftPadding: weekNumberColumn.width * 1

                Label {
                    text: date.getFullYear()
                    color: Material.color(Material.Grey, Material.Shade200)
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "Roboto Regular"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                Label {
                    text: date.toLocaleString(Qt.locale(), "ddd d MMMM")
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Roboto Regular"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        RowLayout {
            id: buttonLayout
            width: gridLayout.width - 8

            RoundButton {
                id: backwardButton
                text: "\ue314"
                font.family: "Material Icons"
                font.pointSize: 20
                padding: 0
                onClicked: goBackward()
                flat: true

            }

            Label {
                text: MDate.shortMonthName(month+1)
                font.bold: true
                font.family: "Roboto Condensed"
                width: 50
                Layout.preferredWidth: width
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            RoundButton {
                id: forwardButton
                text: "\ue315"
                font.family: "Material Icons"
                onClicked: goForward()
                font.pointSize: 20
                flat: true
            }

            RoundButton {
                text: "\ue314"
                font.family: "Material Icons"
                font.pointSize: 20
                padding: 0
                onClicked: year--
                flat: true

            }

            Label {
                text: year
                font.bold: true
                width: 30
                Layout.preferredWidth: width
                //                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            RoundButton {
                text: "\ue315"
                font.family: "Material Icons"
                font.pointSize: 20
                flat: true
                onClicked: year++
            }
        }

        GridLayout {
            id: gridLayout
            columns: 2
            rowSpacing: 0
            columnSpacing: rowSpacing

            Item { width: weekNumberColumn.width; height: width}

            DayOfWeekRow {
                Layout.fillWidth: true
                implicitHeight: Units.rowHeight
                spacing: grid.spacing
                locale: grid.locale
                delegate: Text {
                    font.family: "Roboto Condensed"
                    text: model.narrowName
                    color: Material.color(Material.Grey, Material.Shade600)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            WeekNumberColumn {
                id: weekNumberColumn
                month: grid.month
                year: grid.year
                locale: grid.locale
                Layout.fillHeight: true
                spacing: grid.spacing
                implicitWidth: Units.rowHeight
                delegate: Text {
                    text: model.weekNumber
                    color: Material.accent
                    font.family: "Roboto Condensed"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MonthGrid {
                id: grid
                month: control.month
                year: control.year
                Layout.fillHeight: true
                spacing: Units.smallSpacing
                delegate: Rectangle {
                    property bool checked: sameDates(control.date, model.date)
                    width: 26
                    height: width
                    anchors.margins: 0
                    radius: 30
                    color: checked ? Material.accent : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: model.day
                        font.family: "Roboto Condensed"
                        height: width
                        color: {
                            if (parent.checked)
                                return "white";
                            else if (model.today)
                                return Material.accent
                            else if (model.date.getMonth() !== control.month)
                                return Material.color(Material.Grey, Material.Shade400)
                            else
                                return "black";
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            //                        if (isSelectedDate) {
                            //                            dateSelected = false;
                            //                        } else {
//                            if (!checked) {
                                control.dateSelect(model.date)
                                dateSelected = true;
//                            }
                        }
                    }
                }
            }
        }
    }
}
