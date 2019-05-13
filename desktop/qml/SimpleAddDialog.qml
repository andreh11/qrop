import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Dialog {
    id: dialog
    
    readonly property string text: textField.text.trim()
    readonly property alias acceptableForm: textField.acceptableInput
    property alias labelText: textField.labelText
    property alias placeHolderTex: textField.placeholderText
    property alias validator: textField.validator

    function prefill(text) {
        textField.text = text
    }
    
    title: qsTr("Add New Item")
    
    onAboutToShow: {
        textField.clear();
        textField.forceActiveFocus();
    }
    
    footer: AddDialogButtonBox {
        width: parent.width
        onAccepted: dialog.accept()
        onRejected: dialog.reject()
        acceptableInput: acceptableForm
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: Units.mediumSpacing
        focus: true
        
        Keys.onReturnPressed: {
            if (textField.acceptableInput)
                dialog.accept();
        }
        Keys.onEscapePressed: dialog.reject()
        Keys.onBackPressed: dialog.reject() // especially necessary on Android
        
        MyTextField {
            id: textField
            width: parent.width
            Layout.fillWidth: true
            Layout.minimumWidth: 100
        }
        
        Layout.fillWidth: true
    }
}
