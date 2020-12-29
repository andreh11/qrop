import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Dialog {
    id: mobileDialog

    property alias combo: mobileCombo
    property alias nameField: mobileField
    property alias text: mobileLbl.text

    parent: Overlay.overlay

    focus: true
    modal: true
    title: 'to be set...'
    standardButtons: Dialog.Ok | Dialog.Cancel

    ColumnLayout {
        spacing: 20
        anchors.fill: parent
        Label {
            id: mobileLbl
            width: parent.width - 5
            wrapMode: Text.WordWrap
            text: 'to be set...'
            Layout.fillWidth: true
        }
        TextField {
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
} // mobileDialog
