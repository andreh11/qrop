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

import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

import "date.js" as MDate

Item {
    id: control
    height: textField.height
    implicitWidth: 200
    Layout.minimumWidth: 140

    property alias floatingLabel: textField.floatingLabel
    property alias labelText: textField.labelText

    property date calendarDate: new Date()
    readonly property string isoDateString: Qt.formatDate(calendarDate, "yyyy-MM-dd")
    property string mode: "date" // date or week
    property bool showDateHelper: true
    property string dateHelperText: mode === "date" ? qsTr("W") + MDate.isoWeek(calendarDate)
                                                    : calendarDate.getDate() + "/" + (calendarDate.getMonth()+1) + "/" + calendarDate.getFullYear()

    signal editingFinished()

    MyTextField {
        id: textField

        width: parent.width
        implicitWidth: 100
        text: mode === "date" ? Qt.formatDate(calendarDate, "dd/MM/yyyy") : MDate.isoWeek(calendarDate)
        inputMethodHints: mode === "date" ? Qt.ImhDate : Qt.ImhDigitsOnly
        inputMask: mode === "date" ? "99/99/9999" : ""
        prefixText: mode === "date" ? "" : qsTr("W")

        onEditingFinished: {
            var newDate = new Date();
            if (mode === "date") {
                newDate.setDate(text.substr(0, 2));
                newDate.setMonth(text.substr(3, 2) - 1);
                newDate.setFullYear(text.substr(6, 4));

                calendarDate = newDate;
            } else {
                var week = text.substr(0, 2);

                calendarDate = mondayOfWeek(week, 2018);
            }

            control.editingFinished();
        }

        Label {
            id: dateHelper
            visible: showDateHelper
            text: dateHelperText
            font.family: "Roboto Regular"
            font.italic: true
            font.pointSize: textField.font.pointSize - 1
            color: Material.color(Material.Grey)
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            anchors.right: calendarButton.left
            anchors.rightMargin: -8
            anchors.bottomMargin: 12
            anchors.bottom: parent.bottom
        }

        RoundButton {
            id: calendarButton
            flat: true
            anchors.right: textField.right
            anchors.rightMargin: -16
            anchors.verticalCenter:  parent.verticalCenter
            font.family: "Font Awesome 5 Free"
            text: "\uf073" // calendar-alt
            font.pointSize: textField.font.pointSize * 1.2

                onClicked: {
                    if (largeDisplay)
                        popup.open();
                    else
                        calendar.visible = true;
                }

                Popup {
                    id: popup
                    y: control.height - calendarButton.height/2
                    x: -control.width + calendarButton.width*2
                    width: contentItem.width
                    height: contentItem.height
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    padding: 0
                    topMargin: 0
                    bottomMargin: 0

                    contentItem: CalendarView {
                        clip: true
                        month: calendarDate.getMonth()
                        year: calendarDate.getFullYear()
                        date: calendarDate

                        onDateChanged: {
                            calendarDate = date;
                            popup.close();
                            control.editingFinished()
                        }
                    }
                }
//            MouseArea {
//                anchors.fill: parent
//            }
        }
    }

    Rectangle {
        id: focusShade
        parent: window.contentItem
        anchors.fill: parent
        opacity: (!largeDisplay && calendar.visible) ? 0.5 : 0
        color: "black"

        Behavior on opacity {
            NumberAnimation {
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: parent.opacity > 0
            onClicked: calendar.visible = false
        }
    }

    Rectangle {
        id: calendar
        parent: window.contentItem
//        anchors.top: control.bottom
//        parent: window.contentItem
        visible: false
        focus: true
        z: 10
        width: childrenRect.width
        height: childrenRect.height

        anchors.centerIn: parent
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }

        CalendarView {
            id: calView
            month: calendarDate.getMonth()
            year: calendarDate.getFullYear()
            onDateChanged: {
                calendarDate = date
                parent.visible = false
                control.editingFinished()
            }
        }
    }
}
