import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

CheckBox {
    id: control

    property bool round: false

    indicator: Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: width
            radius: round ? 50 : 4
            color: checked ? Material.accent
                           : Material.color(Material.Green, Material.Shade400)
            Text {
                visible: !control.checked && !hovered
                anchors.centerIn: parent
                text: control.text.slice(0,2)
                color: "white"
                font.family: "Roboto Bold"
                font.pixelSize: 14
            }
            Text {
                visible: control.checked || hovered
                anchors.centerIn: parent
                text: "\ue876"
                color: "white"
                font.family: "Material Icons"
                font.pixelSize: 16
            }
        }

    contentItem: Text {}
//        text: control.text
//        font: control.font
//        opacity: enabled ? 1.0 : 0.3
//        color: control.down ? "#17a81a" : "#21be2b"
//        verticalAlignment: Text.AlignVCenter
//        leftPadding: control.indicator.width + control.spacing
//    }
}
