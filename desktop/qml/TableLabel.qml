import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Label {
    id: label
    font.family: "Roboto Condensed"
    font.pixelSize: 14
//    ToolTip.visible: mouseArea.containsMouse
//    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
//    ToolTip.text: text

    ToolTip {
    visible: mouseArea.containsMouse
    delay: Qt.styleHints.mousePressAndHoldInterval
    text: label.text
    x: label.width / 2
    y: label.height + 16

    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
