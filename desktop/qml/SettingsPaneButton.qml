import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

RowLayout {
    id: control

    property alias text: label.text

    signal clicked

    Layout.fillWidth: true
    Layout.leftMargin: Units.mediumSpacing
    Layout.rightMargin: Layout.leftMargin
    
    Label {
        id: label
        Layout.fillWidth: true
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        elide: Text.ElideRight
        MouseArea {
            anchors.fill: parent
            onClicked: control.clicked()
        }
    }
    
    RoundButton {
        text: "\ue315"
        font.family: "Material Icons"
        font.pixelSize: 22
        flat: true
        onClicked: control.clicked()
    }
}
