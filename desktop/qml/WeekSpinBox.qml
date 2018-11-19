import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Item {
    id: control
    
    property int week: 1
    property int year: 2018
    
    function previousWeek() {
        if (week == 1) {
            week = 52;
            year--;
        } else {
            week--;
        }
    }
    
    function nextWeek() {
        if (week == 52) {
            week = 1;
            year++
        } else {
            week++;
        }
    }
    
    implicitHeight: buttonLayout.implicitHeight
    implicitWidth: buttonLayout.implicitWidth
    height: implicitHeight
    width: implicitWidth
    
    RowLayout {
        id: buttonLayout
        anchors.fill: parent
        spacing: Units.smallSpacing
        
        RoundButton {
            id: previousYearButton
            text: "\ue314"
            font.family: "Material Icons"
            font.bold: true
            font.pointSize: 20
            Material.foreground: Material.accent
            Layout.rightMargin: -32
            onClicked: year--
            flat: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Previous year")
        }
        
        RoundButton {
            id: previousWeekButton
            text: "\ue314"
            font.family: "Material Icons"
            Layout.rightMargin: -16
            font.pointSize: 20
            onClicked: previousWeek()
            flat: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Previous week")
        }
        
        TextInput {
            id: weekInput
            text: week
            font.family: "Roboto Regular"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 20
            Layout.preferredWidth: width
            onAccepted: week = Number(text)
        }
        
        TextInput {
            id: yearInput
            text: year
            width: 30
            font.family: "Roboto Regular"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            onAccepted: year = Number(text)
        }
        
        RoundButton {
            id: nextWeekButton
            text: "\ue315"
            font.family: "Material Icons"
            font.pointSize: 20
            Layout.leftMargin: -16
            flat: true
            onClicked: nextWeek()
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Next week")
        }
        
        RoundButton {
            id: nextYearButton
            text: "\ue315"
            font.family: "Material Icons"
            font.bold: true
            Material.foreground: Material.accent
            font.pointSize: 20
            Layout.leftMargin: -32
            flat: true
            onClicked: year++
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Next year")
        }
    }
}
