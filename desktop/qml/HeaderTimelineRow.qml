import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0

import io.qrop.components 1.0

Row {
    id: headerTimelineRow
    property int season: 1
    
    Repeater {
        model: QrpDate.monthsOrder(season)
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
//                text: Qt.locale().monthName(modelData, Locale.ShortFormat)
                text: QrpDate.shortMonthName(modelData + 1)
                anchors.left: lineRectangle.right
                font.family: Units.headerFont["family"]
                font.pixelSize: Units.fontSizeTable
                color: Units.colorHighEmphasis
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
