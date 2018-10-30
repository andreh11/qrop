import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Pane {
    id: control
    property alias text: label.text
    implicitHeight: 48
    implicitWidth: 344
    padding: 0
    Material.elevation: 6

    signal clicked()

    function open() {
        control.visible = true
        timer.start()
    }

    Timer {
        id: timer
        interval: 5000
        running: false
        onTriggered: control.visible = false
    }

    Rectangle {
        color: Qt.rgba(0, 0, 0, 0.87)
        radius: 4
        anchors.fill: parent

        Label {
            id: label
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            rightPadding: leftPadding
            font.pixelSize: Units.fontSizeBodyAndButton
            font.family: "Roboto Regular"
            color: "#ffffffde"
        }

        Button {
            flat: true
            text: qsTr("Cancel")
            anchors.right: parent.right
            anchors.rightMargin: 8
            Material.foreground: Material.accent
            onClicked: {
                control.visible = false
                control.clicked()
            }
        }
    }

}
