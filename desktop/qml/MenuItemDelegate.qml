import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

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
