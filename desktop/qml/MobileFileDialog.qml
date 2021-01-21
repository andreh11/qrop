import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Dialog {
    id: root

    property alias combo: mobileCombo
    property alias nameField: mobileField
    property alias text: mobileLbl.text
    property alias acceptText: acceptButton.text
    property bool formAccepted: mobileCombo.visible || mobileField.acceptableInput

    onAboutToShow: {
        mobileField.clear();
        mobileField.hasError = false;
    }

    function doValidation() {
        if (formAccepted)
            root.accept();
        else {
            mobileField.hasError = true;
            mobileField.errorText = qsTr("Filename can't be empty");
        }
    }

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
            validator: RegExpValidator { regExp: /\S.*/ }

            Keys.onReturnPressed: {
                nextItemInFocusChain().forceActiveFocus(); // to force validation
                doValidation();
            }
            Keys.onEscapePressed: root.reject()
            Keys.onBackPressed: root.reject() // especially necessary on Android
        }
        ComboBox {
            id: mobileCombo
            Layout.fillWidth: true
            focus: true
        }
    }

    footer: DialogButtonBox {
        Button {
            id: acceptButton
            focus: true
            text: qsTr("OK")
            flat: true
            Material.foreground: Material.accent
            onClicked: doValidation();
        }
        Button {
            text: qsTr("Cancel")
            flat: true
            Material.foreground: Material.accent
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
