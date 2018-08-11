import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Label {
    id: label
    font.family: "Roboto Condensed"
    font.pixelSize: 14
    anchors.verticalCenter: parent.verticalCenter
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
    ToolTip.text: text

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
