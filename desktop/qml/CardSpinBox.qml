import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

MSpinBox {
    id: control
    editable: true
    font.family: "Roboto Regular"
    font.pixelSize: 16
    
    contentItem: TextInput {
        padding: 0
        text: control.textFromValue(control.value, control.locale)
        anchors.verticalCenter: parent.verticalCenter
        
        font: control.font
        color: "black"
        selectionColor: "#21be2b"
        selectedTextColor: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    
    up.indicator: Rectangle {
//        x: control.mirrored ? 0 : parent.width - width
        x: control.mirrored ? parent.width : 0
        height: parent.height
        implicitWidth: 40
        //                        implicitHeight: 40
        color: control.up.pressed ? "#e4e4e4" : "white"
        //                        border.color: enabled ? "#21be2b" : "#bdbebf"
        
        Text {
            text: "\ue315"
            font.family: "Material Icons"
            font.pixelSize: control.font.pixelSize * 2
            color: Material.color(Material.Grey)
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        implicitWidth: 40
        //                        implicitHeight: 40
        color: control.down.pressed ? "#e4e4e4" : "white"
                                border.color: enabled ? "#21be2b" : "#bdbebf"
        
        Text {
            text: "\ue314"
            font.family: "Material Icons"
            font.pixelSize: control.font.pixelSize * 2
            color: Material.color(Material.Grey)
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    background: Rectangle {
        height: parent.height
        //                        implicitWidth: 140
        //                        border.color: "#bdbebf"
    }
    
}
