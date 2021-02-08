import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.12

import io.qrop.components 1.0

Label {
    font.family: "Roboto Regular"
    wrapMode: Label.Wrap
    font.pixelSize: Units.fontSizeBodyAndButton
    horizontalAlignment: Text.AlignHCenter
    onLinkActivated: Qt.openUrlExternally(link)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
