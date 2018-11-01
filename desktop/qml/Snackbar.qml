import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Popup {
    id: control
    property alias text: label.text
    property alias actionText: actionButton.text
    property int duration: 5000

    implicitHeight: 48
    implicitWidth: 344
    padding: 0
    Material.elevation: 6
    closePolicy: Popup.NoAutoClose

    signal clicked()

    onOpened: timer.start()

    enter: Transition {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 150 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    exit: Transition {
        // shrink_fade_out
        //        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    Timer {
        id: timer
        interval: control.duration
        running: false
        onTriggered: control.close()
    }

    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.87)
        radius: 4
    }

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
        id: actionButton
        flat: true
        text: ""
        visible: text
        anchors.right: parent.right
        anchors.rightMargin: 8
        Material.foreground: Material.accent
        onClicked: {
            control.close()
            control.clicked()
        }
    }
}
