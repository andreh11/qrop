import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Dialog {
    id: root

    property alias combo: mobileCombo
    property alias nameField: mobileField
    property alias text: mobileLbl.text
    property bool formAccepted: mobileField.text

    onAboutToShow: mobileField.clear()

    parent: Overlay.overlay
    focus: true
    modal: true

    ColumnLayout {
        spacing: 20
        anchors.fill: parent
        Label {
            id: mobileLbl
            width: parent.width - 5
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
            color: Units.colorMediumEmphasis
            wrapMode: Label.Wrap
            Layout.fillWidth: true
        }
        MyTextField {
            id: mobileField
            focus: true
            Layout.fillWidth: true
        }
        ComboBox {
            id: mobileCombo
            Layout.fillWidth: true
            focus: true
        }
    }

    footer: DialogButtonBox {
        Button {
            text: qsTr("OK")
            flat: true
            enabled: formAccepted
            Material.foreground: Material.accent
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
        Button {
            text: qsTr("Cancel")
            flat: true
            Material.foreground: Material.accent
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
