import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Row {
    id: gridRow
    spacing: monthWidth - 1
    
    Repeater {
        model: 13
        Rectangle {
            height: parent.height
            width: 1
            color: Qt.rgba(0, 0, 0, 0.12)
        }
    }
}
