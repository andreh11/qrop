import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtCharts 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0
import "date.js" as MDate

Button {
    id: noteButton

    text: qsTr("Notes")
    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Units.mediumSpacing
        anchors.rightMargin: anchors.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Units.smallSpacing
        
        Label {
            id: noteIcon
            text: "\ue8cd"
            color: "white"
            font.pixelSize: 22
            font.family: "Material Icons"
        }
        
        Label {
            id: noteLabel
            text: noteButton.text
            color: "white"
            font.pixelSize: Units.fontSizeBodyAndButton
            font.family: "Roboto Regular"
        }
    }
    
    background: Rectangle {
        implicitWidth: noteButton.contentItem.implicitWidth + 2*Units.mediumSpacing
        implicitHeight: 52
        opacity: enabled ? 1 : 0.3
        radius: 4
        color: "black"
    }
}
