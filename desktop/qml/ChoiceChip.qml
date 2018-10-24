import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

AbstractButton {
    id: control
    checkable: true
    height: 32
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 8
    hoverEnabled: true

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: control.checked = !control.checked
    }

    background: Rectangle {
        radius: 32
        color: checked ? Material.color(Material.Cyan, Material.Shade100) :
                         focus ? Material.color(Material.Grey, Material.Shade500) :
                                 hovered ? Material.color(Material.Grey, Material.Shade400) :
                                           Material.color(Material.Grey, Material.Shade300)
    }

    contentItem: Text {
        height: 32
        leftPadding: 12
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0

        color: checked ? Material.color(Material.Blue, Material.Shade800)
                       : Material.color(Material.Grey, Material.Shade800)
        text: control.text
        font.family: "Roboto Regular"
        font.pixelSize: 14


        ColorAnimation on color {
            duration: 2000
        }

    }
}
