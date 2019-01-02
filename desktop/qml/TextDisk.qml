import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Button {
    id: control
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    property alias color: rectangle.color

    background: Rectangle {
        id: rectangle
        implicitWidth: 48
        implicitHeight: 48

        // external vertical padding is 6 (to increase touch area)
        x: 6
        y: 6
        width: parent.width - 12
        height: parent.height - 12
//        radius: control.radius
        radius: 50
        color:  Material.color(Material.Green, Material.Shade400)
        layer.enabled: control.enabled && control.Material.buttonColor.a > 0

        Label {
            anchors.centerIn: parent
            text: control.text.slice(0,2)
            color: "white"
            font.family: "Roboto Bold"
            font.pixelSize: Units.fontSizeSubheading
        }

    }

    contentItem: Label {
    }
}
