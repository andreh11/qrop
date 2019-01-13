import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Dialog {
    id: dialog
    
    readonly property string cropName: familyNameField.text.trim()
    property alias color: colorPicker.color
    property bool acceptableForm: familyNameField.acceptableInput
    
    title: qsTr("Add New Family")
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    onOpened: {
        familyNameField.text = ""
        familyNameField.forceActiveFocus();
    }
    
    footer: AddDialogButtonBox {
        width: parent.width
        onAccept: dialog.accept()
        onReject: dialog.reject()
        acceptableInput: acceptableForm
    }
    
    ColumnLayout {
        Keys.onReturnPressed: if (acceptableForm) dialog.accept();
        Keys.onEscapePressed: dialog.reject()
        Keys.onBackPressed: dialog.reject() // especially necessary on Android
        anchors.fill: parent
        spacing: Units.mediumSpacing
        
        MyTextField {
            id: familyNameField
            labelText: qsTr("Family")
            validator: RegExpValidator { regExp: /\w[\w -]*/ }
            Layout.fillWidth: true
            Layout.minimumWidth: 200
            Keys.onReturnPressed: if (acceptableForm && !popup.opened) dialog.accept();
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            implicitHeight: contentHeight
            spacing: 4
            
            Label {
                text: qsTr("Color")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeCaption
                Material.foreground: Material.accent
            }
            
            ColorPicker {
                id: colorPicker
                Layout.fillWidth: true
                implicitWidth: parent.width
            }
        }
    }
    
}
