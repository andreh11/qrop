import QtQuick 2.11
import QtQuick.Controls 2.4

ItemDelegate {
    id: control
    contentItem: Text {
        rightPadding: control.spacing
        text: control.text
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        color: Qt.rgba(0,0,0,87)
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
}
