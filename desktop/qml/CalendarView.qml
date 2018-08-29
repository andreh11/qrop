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
        console.log("forward!")
        if (month == 11) {
            month = 0;
            year = year + 1;
        } else {
            month++;
        }
    }

    RowLayout {
        id: buttonLayout
        Button {
            text: "<"
            width: 20
            onClicked: goBackward()
        }

        Label {
            text: (month + 1) + " " + year
            font.bold: true
            Layout.fillWidth: true
        }

        Button {
            id: forwardButton
            width: 20
            text: ">"
            onClicked: goForward()
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
            //            locale: Qt.locale("fr_FR")
            Layout.fillHeight: true
            delegate: RoundButton {
                property bool isSelectedDate: model.date.valueOf() === control.date.valueOf()
                text: model.day
                font.family: "Roboto Condensed"
                //                width: 35
                height: width
                checkable: true
                checked: isSelectedDate
                Material.background: checked ? Material.accent : model.today ? Material.color(Material.Grey, Material.Shade400) : "transparent"

                contentItem: Text {
                    text: parent.text
                    font: control.font
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
