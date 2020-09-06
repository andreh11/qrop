/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
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
    property bool selectYear: yearButton.checked

    // Own signal emitted to preserve date binding.
    signal dateSelect(date newDate)

    width: gridLayout.width + 24
    height: dayBox.height + buttonLayout.height + gridLayout.height + 16

    function range(start, end) {
        return (new Array(end - start + 1)).fill(undefined).map((_, i) => i + start);
    }

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
        return new Date(2018, month, 1);
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
            spacing: 0
            width: gridLayout.width
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                text: "%1".arg(MDate.monthName(month + 1))
                font.family: "Roboto Medium"
                font.capitalization: Font.Capitalize
                font.pixelSize: Units.fontSizeBodyAndButton
                color: Units.colorMediumEmphasis
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignLeft
                Layout.preferredWidth: implicitWidth

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Units.shortDuration
                        easing.type: Easing.InQuad
                    }
                }
            }

            Label {
                text: "%1".arg(year)
                font.family: "Roboto Medium"
                font.capitalization: Font.Capitalize
                font.pixelSize: Units.fontSizeBodyAndButton
                color: Units.colorMediumEmphasis
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignLeft
                Layout.leftMargin: 4
            }

            RoundButton {
                id: yearButton
                text: checked ? "\ue5c7" : "\ue5c5"
                font.family: "Material Icons"
                Material.foreground: Units.colorMediumEmphasis
                font.pointSize: Units.fontSizeSubheading
                Layout.leftMargin: - ((background.width - contentItem.width) / 4)
                checkable: true
                flat: true
            }

            Item { Layout.fillWidth: true }

            RoundButton {
                id: backwardButton
                visible: !selectYear
                text: "\ue314"
                font.family: "Material Icons"
                Material.foreground: Units.colorMediumEmphasis
                font.pointSize: Units.fontSizeSubheading
                padding: 0
                flat: true

                ToolTip.visible: hovered
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.text: qsTr("Previous month")

                onClicked: goBackward()
            }

            RoundButton {
                id: forwardButton
                visible: !selectYear
                text: "\ue315"
                font.family: "Material Icons"
                Material.foreground: Units.colorMediumEmphasis
                font.pointSize: Units.fontSizeSubheading
                flat: true
                Layout.rightMargin: - ((background.width - contentItem.width) / 4)

                ToolTip.visible: hovered
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.text: qsTr("Next month")

                onClicked: goForward()
            }
        }

        GridLayout {
            id: gridLayout
            visible: !selectYear
            columns: 2
            rowSpacing: 0
            columnSpacing: rowSpacing

            Item {
                width: weekNumberColumn.width
                height: width
            }

            DayOfWeekRow {
                Layout.fillWidth: true
                implicitHeight: Units.rowHeight
                spacing: grid.spacing
                locale: grid.locale
                delegate: Text {
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeCaption
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
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeCaption
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
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeCaption
                        height: width
                        color: {
                            if (parent.checked)
                                return "white"
                            else if (model.today)
                                return Material.accent
                            else if (model.date.getMonth() !== control.month)
                                return Material.color(Material.Grey,
                                                      Material.Shade400)
                            else
                                return "black"
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
                            dateSelected = true
                            //                            }
                        }
                    }
                }
            }
        }

        GridLayout {
            id: yearGridLayout
            visible: control.selectYear
            width: gridLayout.width
            height: gridLayout.height
            columns: 4
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                model: range(control.year - 10, control.year + 17)
                Item {
                    property bool checked: control.year == modelData

                    width: 56
                    height: 32
                    Rectangle {
                        width: 52
                        height: 28
                        radius: 30
                        color: checked ? Material.accent : "transparent"
                        anchors.centerIn: parent
                    }

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: "Roboto Regular"
                        height: width
                        color: {
                            if (parent.checked)
                                return "white"
                            else
                                return "black"
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            yearButton.toggle()
                            control.year = modelData
                        }
                    }
                }
            }
        }
    }
}
