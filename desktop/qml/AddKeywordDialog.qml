import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Dialog {
    id: dialog

    property alias fieldName: textField.labelText
    readonly property string fieldText: textField.text.trim()
    property bool acceptableForm: textField.acceptableInput

    title: qsTr("Add New Family")
    standardButtons: Dialog.Ok | Dialog.Cancel

    onOpened: {
        textField.text = ""
        textField.forceActiveFocus();
    }

    footer: AddDialogButtonBox {
        width: parent.width
        onAccept: dialog.accept()
        onReject: dialog.reject()
        acceptableInput: acceptableForm
    }

    MyTextField {
        id: textField
        labelText: qsTr("Keyword")
        validator: RegExpValidator { regExp: /\w[\w -]*/ }
        Layout.fillWidth: true
        Layout.minimumWidth: 200
        Keys.onReturnPressed: if (acceptableForm ) dialog.accept();
        Keys.onEnterPressed: if (acceptableForm) dialog.accept();
    }
}
