import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Column {
    id: control

    property int firstColumnWidth
    property int secondColumnWidth

    signal refresh()

    Rectangle {
        color: Material.color(Material.Grey, Material.Shade100)
        width: parent.width
        height: childrenRect.height
        
        MouseArea {
            id: familyMouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true
            
            RowLayout {
                id: headerRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Units.rowHeight
                spacing: Units.formSpacing
                
                TextDisk {
                    id: headerCheckbox
                    text: family.slice(0,2)
                    color: model.color
//                    Layout.preferredWidth: Units.rowHeight * 0.8
//                    Layout.preferredHeight: Units.rowHeight * 0.8
                    Layout.leftMargin: Units.mediumSpacing
                    onClicked: colorPickerDialog.open()

                    Dialog {
                        id: colorPickerDialog
                        width: 400
                        height: 400
                        ColorPicker {
                            anchors.fill: parent
                            onNewColorSelected: {
                                colorPickerDialog.close()
                                Family.update(model.family_id, {"color": color});
                                refresh();
                            }
                        }
                    }
                }

                TextInput {
                    text: family
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    Layout.minimumWidth: pane.firstColumnWidth
                    onEditingFinished: {
                        Family.update(family_id, {"family": text})
                        refresh();
                    }
                }
                
                ComboBox {
                    flat: true
                    model: 10
                    Layout.minimumWidth: pane.secondColumnWidth
                    currentIndex: interval
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    displayText: qsTr("%L1 years", "", currentIndex).arg(currentIndex)
                    onCurrentIndexChanged: Family.update(family_id, {"interval": currentIndex})
                    
                    ToolTip.text: qsTr("Minimum rotation interval for %1").arg(family)
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                }
                
                
                Item { Layout.fillWidth: true }
                
                MyToolButton {
                    visible: familyMouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove family")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    
                    onClicked: confirmFamilyDeleteDialog.open()
                    
                    Dialog {
                        id: confirmFamilyDeleteDialog
                        title: qsTr("Delete %1?").arg(family)
                        standardButtons: Dialog.Ok | Dialog.Cancel
                        
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All crops and plantings will be lost.")
                        }
                        
                        onAccepted: {
                            Family.remove(family_id)
                            refresh();
                        }
                        
                        onRejected: confirmFamilyDeleteDialog.close()
                    }
                }
                
                MyToolButton {
                    id: showCropsButton
                    Layout.leftMargin: -28
                    Layout.rightMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    checkable: true
                    text: checked ?  "\ue313" : "\ue315"
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: checked ? qsTr("Hide crops") : qsTr("Show crop")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                }
            }
        }
    }
    
    ListView {
        id: cropView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        spacing: 0
        visible: showCropsButton.checked
        width: parent.width
        height: contentHeight
        
        model: CropModel {
            id: cropModel
            familyId: family_id
        }
        
        delegate: SettingsCropDelegate {
            width: parent.width
            onRefresh: cropModel.refresh()
            firstColumnWidth: control.firstColumnWidth
            secondColumnWidth: control.secondColumnWidth
        }
    }

        Button {
        id: addCropButton
        visible: showCropsButton.checked
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        text: qsTr("Add crop")
        flat: true
        Material.foreground: Material.accent
        onClicked: addCropDialog.open();
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.rightMargin: Units.formSpacing

        AddCropDialog {
            id: addCropDialog
            alreadyAssignedFamilyId: true
            onAccepted: {
                Crop.add({"crop" : cropName,
                             "family_id" : family_id,
                             "color" : color});
                cropModel.refresh();
            }
        }
        }
}
