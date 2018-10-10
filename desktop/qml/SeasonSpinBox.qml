import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Item {
    id: control

    implicitHeight: buttonLayout.implicitHeight
    implicitWidth: buttonLayout.implicitWidth
    height: implicitHeight
    width: implicitWidth

    property int season: 0
    property int year: 2018
    readonly property var seasonNames: [qsTr("Spring"), qsTr("Summer"), qsTr("Fall"), qsTr("Winter")]

    function previousSeason() {
        if (season == 0) {
            season = 3;
            year--;
        } else {
            season--;
        }
    }

    function nextSeason() {
        if (season == 3) {
            season = 0;
            year++
        } else {
            season++;
        }
    }

    RowLayout {
        id: buttonLayout
        anchors.fill: parent
        spacing: 8

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
            id: previousSeasonButton
            text: "\ue314"
            font.family: "Material Icons"
            Layout.rightMargin: -16
            font.pointSize: 20
            onClicked: previousSeason()
            flat: true
            ToolTip.visible: hovered
        ToolTip.text: qsTr("Previous season")
        }

        Label {
            text: seasonNames[season]
            font.family: "Roboto Regular"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 60
            Layout.preferredWidth: width
        }


        Label {
            text: year
            font.family: "Roboto Regular"
//            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        RoundButton {
            id: nextSeasonButton
            text: "\ue315"
            font.family: "Material Icons"
            font.pointSize: 20
            Layout.leftMargin: -16
            flat: true
            onClicked: nextSeason()
            ToolTip.visible: hovered
        ToolTip.text: qsTr("Next season")
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
