import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Item {
    id: control
    height: textField.height
//    width: textField.width

    property date calendarDate: new Date()
    property string mode: "date" // date or week
    property bool showDateHelper: true
    property string dateHelperText: mode === "date" ? qsTr("W") + isoWeek(calendarDate)
                                                    : calendarDate.getDate() + "/" + (calendarDate.getMonth()+1) + "/" + calendarDate.getFullYear()


    MyTextField {
        id: textField

        floatingLabel: true
        width: parent.width
        implicitWidth: 100
        text: mode === "date" ? Qt.formatDate(calendarDate, "dd/MM/yyyy") : isoWeek(calendarDate)
        placeholderText: "Seeding date"
        inputMethodHints: mode === "date" ? Qt.ImhDate : Qt.ImhDigitsOnly
        inputMask: mode === "date" ? "99/99/9999" : ""
//        suffixTextAddedMargin: iconLabel.width + 8
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
                onClicked: calendar.visible = true
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
        z: 10
        width: 400
        height: width

        anchors.centerIn: parent
//        onClicked: visible = false
        Keys.onBackPressed: {
            event.accepted = true;
            visible = false;
        }

        CalendarView {
            anchors.fill: parent
            id: calendarView
            month: calendarDate.getMonth()
            year: calendarDate.getFullYear()
            onDateChanged: calendarDate = date
        }

        MouseArea {
            anchors.fill: parent
//            onClicked: parent.visible = false

        }
    }
}
