import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Item {
    id: control
    
    property int week: 1
    property int year: 2018
    onYearChanged: console.log(year, longYear, lastWeek)
    property bool longYear: MDate.longYear(year)
    property int lastWeek: longYear ? 53 : 52
    property bool showOnlyYear: false
    
    function previousYear() {
        let setLastWeek = false;
        if (week == 53)
            setLastWeek = true;
        year--;
        if (setLastWeek)
            week = lastWeek;
    }

    function nextYear() {
        let setLastWeek = false;
        if (week == 53)
            setLastWeek = true;
        year++;
        if (setLastWeek)
            week = lastWeek;
    }

    function previousWeek() {
        if (week == 1) {
            year--;
            week = lastWeek;
        } else {
            week--;
        }
    }
    
    function nextWeek() {
        if (week == lastWeek) {
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

    MouseArea {
        anchors.fill: parent
        onWheel: {
            if (wheel.angleDelta.y > 0) {
                if (showOnlyYear || (wheel.modifiers & Qt.ControlModifier))
                    nextYear();
                else
                    nextWeek();
            } else if (wheel.angleDelta.y < 0) {
                if (showOnlyYear || (wheel.modifiers & Qt.ControlModifier))
                    previousYear();
                else
                    previousWeek();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        //        border.color: Material.accent
        //        border.width: 1
        color: Material.color(Material.Grey, Material.Shade400)
        radius: 4
        opacity: 0.1
    }

    RowLayout {
        id: buttonLayout
        anchors.fill: parent
        spacing: Units.smallSpacing
        
        TextInput {
            id: weekInput
            text: week
            visible: !showOnlyYear
            font.family: "Roboto Regular"
            font.pointSize: 10
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 1; top: 53 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 20
//            Layout.preferredWidth: width
            onTextChanged: week = Number(text)
            Layout.preferredWidth: 30
        }
        
        TextInput {
            id: yearInput
            text: year
            width: 30
            Layout.preferredWidth: showOnlyYear ? 40 : 30
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { bottom: 1; top: 53 }
            font.family: "Roboto Regular"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            onTextChanged: year = Number(text)
        }
        
        ColumnLayout {
            spacing: -8
            Layout.rightMargin: 4

            Label {
                id: nextSeasonButton
                text: "\ue5ce"
                font.family: "Material Icons"
                font.pointSize: 16
                color: nextMouseArea.pressed ? Qt.rgba(0,0,0,0.38) : "black"

                MouseArea {
                    id: nextMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if (showOnlyYear || (mouse.modifiers & Qt.ControlModifier))
                            nextYear();
                        else
                            nextWeek();
                    }
                }

                ToolTip.visible: nextMouseArea.containsMouse
                ToolTip.text: qsTr("Next season")
            }

            Text {
                id: previousWeekButton
                text: "\ue5cf"
                font.family: "Material Icons"
                //            Layout.rightMargin: -16
                font.pointSize: 16
                //            flat: true
                ToolTip.visible: previousMouseArea.containsMouse
                ToolTip.text: qsTr("Previous season")
                color: previousMouseArea.pressed ? Qt.rgba(0,0,0,0.38) : "black"

                MouseArea {
                    id: previousMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if (showOnlyYear || (mouse.modifiers & Qt.ControlModifier))
                            previousYear();
                        else
                            previousWeek();
                    }
                }
            }

        }
    }
}
