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

Item {
    id: control
    height: textField.height
    implicitWidth: 200
    Layout.minimumWidth: 140
    property alias floatingLabel: textField.floatingLabel
    property alias placeholderText: textField.placeholderText

    property date calendarDate: new Date()
    property string mode: "date" // date or week
    property bool showDateHelper: true
    property string dateHelperText: mode === "date" ? qsTr("W") + isoWeek(calendarDate)
                                                    : calendarDate.getDate() + "/" + (calendarDate.getMonth()+1) + "/" + calendarDate.getFullYear()

    signal editingFinished()

    MyTextField {
        id: textField

        width: parent.width
        implicitWidth: 100
        text: mode === "date" ? Qt.formatDate(calendarDate, "dd/MM/yyyy") : isoWeek(calendarDate)
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
            anchors.right: iconLabel.right
            anchors.rightMargin: 24
            anchors.bottomMargin: 16
            anchors.bottom: parent.bottom
        }

        Label {
            id: iconLabel
            bottomPadding: 6
            anchors.right: textField.right
            anchors.rightMargin: 12
            anchors.verticalCenter:  parent.verticalCenter
            font.family: "Font Awesome 5 Free"
            text: "\uf073" // calendar-alt
            font.pointSize: textField.font.pointSize * 1.3

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (largeDisplay)
                        popup.open();
                    else
                        calendar.visible = true;
                }

                Popup {
                    id: popup
                    y: control.height/2
                    x: -control.width
                    width: contentItem.width
                    height: contentItem.height
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                    padding: 0

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
            }
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
