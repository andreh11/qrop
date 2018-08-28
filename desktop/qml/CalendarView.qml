import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.calendar 1.0

Item {
    id: control
    property date date: new Date()

    ColumnLayout {
        Label {
            text: (date.getMonth() + 1) + " " + date.getFullYear()
            font.bold: true
            Layout.fillWidth: true
        }

        DayOfWeekRow {
            locale: grid.locale
            Layout.fillWidth: true
        }

        RowLayout {
            WeekNumberColumn {
                month: grid.month
                year: grid.year
                locale: grid.locale
                Layout.fillHeight: true
                delegate: Text {
                      text: model.weekNumber
                      color: Material.color(Material.Blue)
//                      font: control.font
                      horizontalAlignment: Text.AlignHCenter
                      verticalAlignment: Text.AlignVCenter
                      MouseArea {
                          anchors.fill: parent
                          hoverEnabled: true
                      }
                  }
            }

            MonthGrid {
                id: grid
                month: Calendar.December
                year: 2015
                locale: Qt.locale("en_US")
                Layout.fillHeight: true
            }
        }
    }
}
