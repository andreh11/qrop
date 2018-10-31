import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0
import "date.js" as MDate

Dialog {
    id: addVarietyDialog
    title: qsTr("Add New Variety")
    standardButtons: Dialog.Ok | Dialog.Cancel

    property alias varietyName: varietyNameField.text
    
    MyTextField {
        id: varietyNameField
        anchors.centerIn: parent
        width: parent.width
        
        Keys.onReturnPressed: {
            if (varietyNameField.text)
                addVarietyDialog.accept();
        }
        Keys.onEscapePressed: addVarietyDialog.reject()
        Keys.onBackPressed: addVarietyDialog.reject() // especially necessary on Android
        
        labelText: qsTr("Variety")
        Layout.fillWidth: true
        Layout.minimumWidth: 100
    }
    
    onOpened: varietyNameField.forceActiveFocus()
}
