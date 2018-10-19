import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Rectangle {
    id: control

    property string text
    signal removeButtonClicked()

    height: 32
    radius: 40
    implicitWidth: contentLabel.width + removeButton.width
    color:  focus ? Material.color(Material.Grey, Material.Shade500) :
                    mouseArea.hovered ? Material.color(Material.Grey, Material.Shade400) :
                                        Material.color(Material.Grey, Material.Shade300)


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

//    RowLayout {
//        id: rowLayout
//        anchors.fill: parent
//        spacing: 0

        Label {
            id: contentLabel
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            color:  Material.color(Material.Grey, Material.Shade800)
            text: control.text
            font.family: "Roboto Regular"
            font.pixelSize: 14
        }

        RoundButton {
            id: removeButton
            flat: true
            anchors.right: parent.right
            anchors.rightMargin: -8
            anchors.verticalCenter: parent.verticalCenter
            Material.foreground: Material.color(Material.Grey,
                                                Material.Shade500)
            text: "\ue5c9" // remove
            font.family: "Material Icons"
            font.pixelSize: 24
            onClicked: removeButtonClicked()
        }
//    }
}
