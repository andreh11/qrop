import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0
import Qt.labs.platform 1.0 as Lab

import io.croplan.components 1.0
import "date.js" as MDate

Dialog {
    id: addCropDialog
    title: qsTr("Add New Crop")
    standardButtons: Dialog.Ok | Dialog.Cancel
    
    property alias cropName: cropNameField.text
    property int familyId: familyModel.rowId(familyField.currentIndex)
    property alias color: colorDialog.color

    onOpened: cropNameField.forceActiveFocus();


    ColumnLayout {
        Keys.onReturnPressed: addCropDialog.accept();
        anchors.fill: parent
        spacing: Units.mediumSpacing
        
        MyTextField {
            id: cropNameField
            labelText: qsTr("Crop")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
        }
        
        MyComboBox {
            id: familyField
            labelText: qsTr("Family")
            Layout.minimumWidth: 150
            Layout.fillWidth: true
            editable: false
            model: FamilyModel {
                id: familyModel
            }
            textRole: "family"
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            implicitHeight: contentHeight
            spacing: 0
            
            Label {
                text: qsTr("Color")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeCaption
                Material.foreground: Material.accent
            }
            
            Button {
                id: buttonColor
                flat: true
                Layout.fillWidth: true
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                onClicked: colorDialog.open()
                Material.background: colorDialog.color
                
                MouseArea {
                    id: colorMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: buttonColor.clicked()
                }
            }
        }
        
        Lab.ColorDialog {
            id: colorDialog
        }
    }
    
}
