import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

GroupBox {
    id: greenhouseBox
    topPadding: title === "" ? 0 : 32
    width: parent.width
    background: Rectangle { anchors.fill: parent }
    padding: 0
    bottomPadding: 16
    label: Label {
        y: 0
        width: greenhouseBox.leftPadding
        text: greenhouseBox.title
        font.family: "Roboto Regular"
        font.pixelSize: fontSizeSubheading
        color: Material.accent
    }
}
