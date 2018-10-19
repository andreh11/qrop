import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Button {
    id: control
    checkable: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 6
    leftPadding: padding - 4
    rightPadding: padding - 4
    spacing: 6


    background: Rectangle {
        color: checked ? Material.color(Material.Cyan, Material.Shade100)
                       : Material.color(Material.Grey, Material.Shade200)
        radius: 32
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: leftPadding
        topPadding: 0
        bottomPadding: 0

        color: checked ? Material.color(Material.Blue, Material.Shade800)
                       : Material.color(Material.Grey, Material.Shade600)
        text: control.text
        font.family: "Roboto Regular"
        font.pixelSize: 14
    }

}
