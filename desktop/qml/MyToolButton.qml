import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

import io.croplan.components 1.0

ToolButton {
    font.family: "Roboto Condensed"
    hoverEnabled: true
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse.accepted = false
    }
    
    Material.foreground: hovered ? "black":  Material.color(Material.Grey, Material.Shade700)
    
}
