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

    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Label {
            id: leadingIcon
            visible: false
        }

        Label {
            id: contentLabel
            padding: 0
            leftPadding: 8
            color:  Material.color(Material.Grey, Material.Shade800)
            text: control.text
            font.family: "Roboto Regular"
            font.pixelSize: 14
        }

        RoundButton {
            id: removeButton
            flat: true
            Layout.fillWidth: true
            Material.foreground: Material.color(Material.Grey,
                                                Material.Shade500)
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            text: "\ue5c9" // remove
            font.family: "Material Icons"
            font.pixelSize: 24
            onClicked: removeButtonClicked()
        }
    }
}
