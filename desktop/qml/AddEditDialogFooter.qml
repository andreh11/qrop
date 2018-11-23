import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2


Item {
    id: control

    property alias applyEnabled: applyButton.enabled
    property string mode: "add"

    signal rejected()
    signal accepted()

    Button {
        id: rejectButton
        flat: true
        text: qsTr("Cancel")
        anchors.right: applyButton.left
        anchors.rightMargin: Units.smallSpacing
        Material.foreground: Material.accent
        onClicked: rejected();
    }
    
    Button {
        id: applyButton
        Material.background: Material.accent
        Material.foreground: "white"
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        text: mode === "add" ? qsTr("Add") : qsTr("Edit")
        onClicked: accepted()
    }
}
