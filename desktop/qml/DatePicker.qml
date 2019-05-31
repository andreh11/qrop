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
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: control

    property alias floatingLabel: textField.floatingLabel
    property alias labelText: textField.labelText
    property alias errorText: textField.errorText
    property alias hasError: textField.hasError
    property int currentYear: MDate.currentYear()

    property date calendarDate: new Date()
    property date effectiveDate
    readonly property int week: MDate.isoWeek(calendarDate)
    readonly property string isoDateString: Qt.formatDate(calendarDate, "yyyy-MM-dd")
    property string mode: "date" // date or week
    property bool showDateHelper: true
    property string dateHelperText: MDate.formatDate(calendarDate, currentYear,
                                                     mode === "date" ? "week" : "date")
    signal editingFinished()

    function clear() {
        textField.clear();
    }

    Settings {
        id: settings
        property alias dateType: control.mode
    }

    height: textField.height
//    implicitWidth: textField.implicitWidth
    Layout.minimumWidth: 100

    MyTextField {
        id: textField

        width: parent.width
        helperText: MDate.isValid(effectiveDate) && effectiveDate !== calendarDate
                    ? qsTr("Done on %1").arg(MDate.formatDate(effectiveDate, currentYear))
                    : ""
        text: MDate.formatDate(calendarDate, currentYear)
        inputMethodHints: mode === "date" ? Qt.ImhDate : Qt.ImhDigitsOnly
        validator: RegExpValidator {
            regExp: mode === "date"
                    ? /^(0{,1}[1-9]|[12]\d|3[01])[/-. ](0{,1}[1-9]|1[012])([/-. ]20\d\d){,1}$/
                    : /^[><]{0,1}([1-9]|[0-4]\d|5[0-3])$/
        }

        onTextEdited: {
            if (!textField.acceptableInput)
                return;

            var newDate = mode === "date" ? MDate.dateFromDateString(text)
                                          : MDate.dateFromWeekString(text);
            if (newDate.toLocaleString(Qt.locale()))
                calendarDate = newDate;

            calendarDateChanged();
            control.editingFinished();
        }

        Label {
            id: dateHelper
            visible: showDateHelper
            text: dateHelperText
            font { family: "Roboto Regular"; italic: true; pointSize: textField.font.pointSize - 2 }
            color: Material.color(Material.Grey)
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            y: (Units.fieldHeight - height)/2
            anchors {
                right: calendarButton.left
                rightMargin: -8
//                bottomMargin: 12
//                bottom: parent.bottom
            }
        }

        RoundButton {
            id: calendarButton
            focusPolicy: Qt.NoFocus
            flat: true
            text: "\ue916" // calendar-alt
            font { pointSize: textField.font.pointSize * 1.4; family: "Material Icons" }
            y: (Units.fieldHeight - height)/2
            anchors {
                right: textField.right
//                rightMargin: -16
//                verticalCenter: control.verticalCenter
            }

            onClicked: {
                if (largeDisplay) {
                    calendarView.resetBindings();
                    popup.open();
                } else {
                    mobileCalendarView.resetBindings();
                    calendar.visible = true;
                }
            }

            Popup {
                id: popup
                y: control.height - calendarButton.height/2
                x: -control.width + calendarButton.width*2
                width: contentItem.width
                height: contentItem.height
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                padding: 0
                margins: 0

                contentItem: CalendarView {
                    id: calendarView

                    clip: true
                    month: calendarDate.getMonth()
                    year: calendarDate.getFullYear()
                    date: calendarDate

                    onDateSelect: {
                        calendarDate = newDate;
                        popup.close();
                        control.editingFinished();
                    }
                }
            }
        }
    }

    // BUG: cannot set cursorShape anymore if we use this trick!
//    Rectangle {
//        id: focusShade
//        parent: window.contentItem
//        anchors.fill: parent
//        opacity: (!largeDisplay && calendar.visible) ? 0.5 : 0
//        color: "black"

//        MouseArea {
//            anchors.fill: parent
//            enabled: parent.opacity > 0
//            onClicked: calendar.visible = false
//        }
//    }

    Rectangle {
        id: calendar
        parent: window.contentItem
        //        anchors.top: control.bottom
        //        parent: window.contentItem
        visible: false
//        focus: true
        z: 10
        width: childrenRect.width
        height: childrenRect.height

        anchors.centerIn: parent
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }

        CalendarView {
            id: mobileCalendarView
            month: calendarDate.getMonth()
            year: calendarDate.getFullYear()
            date: calendarDate
            onDateSelect: {
                calendarDate = newDate;
                parent.visible = false;
                control.editingFinished();
            }
        }
    }
}
