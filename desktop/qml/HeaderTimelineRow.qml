import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0

Row {
    id: headerTimelineRow
    property int season: 1
    
    Repeater {
        model: monthsOrder[season]
        Item {
            width: Units.monthWidth
            height: parent.height
            
            Rectangle {
                id: lineRectangle
                height: parent.height
                width: 1
                color: Qt.rgba(0, 0, 0, 0.12)
            }
            
            Label {
                text: Qt.locale().monthName(modelData, Locale.ShortFormat)
                anchors.left: lineRectangle.right
                font.family: "Roboto Condensed"
                color: Material.color(Material.Grey, Material.Shade700)
                width: 60 - 1
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    
    Rectangle {
        height: parent.height
        width: 1
        color: Qt.rgba(0, 0, 0, 0.12)
    }
}