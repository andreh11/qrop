import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import QtCharts 2.2

import io.qrop.components 1.0

Pane {
    Material.elevation: 1


    property alias title: titleLabel.text
    property alias text: textLabel.text


    Label {
        id: titleLabel
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        color: "white"
        anchors {
            left: parent.left
            top: parent.top
            margins: 4
        }
    }
    
    Label {
        id: textLabel
        text: qsTr("$%L1").arg(Planting.revenue(page.year))
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeHeadline
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        
        anchors {
            top: titleLabel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
