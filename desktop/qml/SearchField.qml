import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.2

import io.croplan.components 1.0
import "date.js" as MDate

TextArea {
    id: filterField
    visible: checks === 0
    leftPadding: searchLogo.width + 16
    font.family: "Roboto Regular"
    font.pixelSize: fontSizeBodyAndButton
    color: "black"
    placeholderText: qsTr("Search")
    padding: 8
    topPadding: 16
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            filterMode = false
            filterField.text = ""
        }
    }
    
    background: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 200
        implicitHeight: 20
        //                        width: parent.width
        height: parent.height * 0.7
        color: Material.color(Material.Grey,
                              Material.Shade400)
        radius: 4
        opacity: 0.1
    }
    
    Label {
        id: searchLogo
        //                    visible: filterField.visible
        color: "black"
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: "\ue8b6" // search
        font.family: "Material Icons"
        font.pixelSize: 24
    }

    RoundButton {
        id: clearButton
        flat: true
        visible: filterField.text
        //                    visible: filterField.visible
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: "\ue5c9" // search
        font.family: "Material Icons"
        font.pixelSize: 24
        onClicked: filterField.clear()
    }

}
