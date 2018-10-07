import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

CheckBox {
    id: control
    checked: true

    indicator:  Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            height: 30
            width: height
            radius: 80
            color: checked ? Material.accent
                           : Material.color(Material.Green, Material.Shade400)
            Text {
                visible: !control.checked && !hovered
                anchors.centerIn: parent
                text: control.text.slice(0,2)
                color: "white"
                font.family: "Roboto Regular"
                font.pixelSize: 16
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

//    indicator: Rectangle {
//        implicitWidth: 26
//        implicitHeight: 26
//        x: control.leftPadding
//        y: parent.height / 2 - height / 2
//        radius: 3
//        border.color: control.down ? "#17a81a" : "#21be2b"

//        Rectangle {
//            width: 14
//            height: 14
//            x: 6
//            y: 6
//            radius: 2
//            color: control.down ? "#17a81a" : "#21be2b"
//            visible: control.checked
//        }
//    }

    contentItem: Text {}
//        text: control.text
//        font: control.font
//        opacity: enabled ? 1.0 : 0.3
//        color: control.down ? "#17a81a" : "#21be2b"
//        verticalAlignment: Text.AlignVCenter
//        leftPadding: control.indicator.width + control.spacing
//    }
}
