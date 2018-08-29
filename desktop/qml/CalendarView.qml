import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0

Item {
    id: control

    property date date: new Date()
    property int month
    property int year
    property bool dateSelected: false

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

    function monthName(month) {
        return firstOfMonth(month).toLocaleString(Qt.locale(), "MMMM")
    }

    RowLayout {
        id: buttonLayout
        width: parent.width
        RoundButton {
            Material.background: "transparent"
            text: "\ue314"
            font.family: "Material Icons"
            font.pointSize: 20
            padding: 0
            onClicked: goBackward()

        }

        Label {
            text: monthName(month) + " " + year
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        RoundButton {
            id: forwardButton
            Material.background: "transparent"
            text: "\ue315"
            font.family: "Material Icons"
            onClicked: goForward()
            font.pointSize: 20
        }
    }

    GridLayout {
        columns: 2
        anchors.top: buttonLayout.bottom

        Item { width: 20; height: width}

        DayOfWeekRow {
            locale: grid.locale
            Layout.fillWidth: true
            delegate: Text {
                font.family: "Roboto Condensed"
                text: model.shortName
                color: "gray"
                width: 35
            }
        }

        WeekNumberColumn {
            month: grid.month
            year: grid.year
            locale: grid.locale
            Layout.fillHeight: true
            delegate: Text {
                text: model.weekNumber
                color: Material.color(Material.Blue)
                font.family: "Roboto Condensed"
                width: 35
                //                      font: control.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }

        Component {
            id: montGridDelegate

            Text {
                font.family: "Roboto Condensed"
                width: 35
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: model.month === control.month ? 1 : 0
                text: model.day
                color: model.today ? "red" : "black"
            }
        }

        MonthGrid {
            id: grid
            month: control.month
            year: control.year
            Layout.fillHeight: true
            delegate: RoundButton {
                property bool isSelectedDate: model.date.valueOf() === control.date.valueOf()
                text: model.day
                font.family: "Roboto Condensed"
                height: width
                checkable: true
                checked: isSelectedDate
                Material.background: checked ? Material.accent : model.today ? Material.color(Material.Grey, Material.Shade400) : "transparent"

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: (parent.checked || model.today) ? "white" : model.date.getMonth() !== control.month ? Material.color(Material.Grey, Material.Shade400) : "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                onClicked: {
                    if (isSelectedDate) {
                        dateSelected = false;
                    } else {
                        control.date = model.date;
                        dateSelected = true;
                    }
                }
            }
        }
    }
}
