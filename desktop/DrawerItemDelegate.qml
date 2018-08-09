import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0


ItemDelegate {
    id: control

    property string page
    property bool isActive: index === navigationIndex
    property string iconText


    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    focusPolicy: Qt.NoFocus
    height: 48
    width: drawer.width
    highlighted: isActive

    contentItem: Row {
        anchors.centerIn: parent
        spacing: largeDisplay && railMode ? 0 : 24
        Label {
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            id: iconLabel
            text: iconText
            font.family: "Material Icons"
            font.pixelSize: 24
            horizontalAlignment: largeDisplay && railMode ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Label {
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            id: textLabel
            text: largeDisplay && railMode ? "" : control.text
            verticalAlignment: Text.AlignVCenter
        }
    }

    onClicked: {
        navigationIndex = index
        if (!largeDisplay) {
            drawer.close()
        }
    }
}
