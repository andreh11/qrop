import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

AbstractButton {
    id: control

    property color color

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    hoverEnabled: true
    padding: 0

    background: Rectangle {
        id: rectangle

        implicitHeight: 36
        implicitWidth: 36

        // external vertical padding is 6 (to increase touch area)
//        x: 6
//        y: 6
//        width: parent.width - 12
//        height: parent.height - 12
        color: control.pressed ? Qt.darker(control.color, 1.2) : (control.hovered ? Qt.darker(control.color, 1.1) : control.color)
//        radius: control.radius
        radius: 50
        layer.enabled: control.enabled && control.Material.buttonColor.a > 0

        Label {
            anchors.centerIn: parent
            text: control.text.slice(0,2)
            color: "white"
            font.family: "Roboto Bold"
            font.pixelSize: Units.fontSizeSubheading
        }

    }

    contentItem: Label { }
}
