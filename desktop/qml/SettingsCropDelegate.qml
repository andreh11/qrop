/*
 * Copyright (C) 2019 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Column {
    signal refresh()

    Rectangle {
        id: delegate
        height: childrenRect.height
        width: parent.width
        
        MouseArea {
            id: cropMouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true
            
            RowLayout {
                id: cropRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Units.rowHeight
                spacing: Units.formSpacing
                
                TextCheckBox {
                    id: checkBox
                    text: model.crop
                    selectionMode: false
                    Layout.leftMargin: Units.mediumSpacing
                    //                                width: 24
                    Layout.preferredWidth: Units.rowHeight * 0.8
                    round: true
                    color: model.color
                }
                
                TextInput {
                    text: model.crop
                    font.family: "Roboto Regular"
                    Layout.minimumWidth: pane.firstColumnWidth
                    onEditingFinished: {
                        Crop.update(model.crop_id, {"crop": text});
                        refresh();
                    }
                }
                
                Item { height: 1; Layout.fillWidth: true }
                
                MyToolButton {
                    visible: cropMouseArea.containsMouse
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove crop")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    
                    onClicked: confirmCropDeleteDialog.open()
                    
                    Dialog {
                        id: confirmCropDeleteDialog
                        title: qsTr("Delete %1?").arg(model.crop)
                        standardButtons: Dialog.Ok | Dialog.Cancel
                        
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All plantings will be lost.")
                        }
                        
                        onAccepted: {
                            Crop.remove(model.crop_id)
                            refresh();
                        }
                        
                        onRejected: confirmCropDeleteDialog.close()
                    }
                }
                
                MyToolButton {
                    id: showVarietiesButton
                    Layout.leftMargin: -28
                    Layout.rightMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    checkable: true
                    text: checked ?  "\ue313" : "\ue315"
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: checked ? qsTr("Hide varieties") : qsTr("Show varieties")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                }
            }
        }
    }
    
    ListView {
        spacing: 0
        visible: showVarietiesButton.checked
        width: parent.width
        height: contentHeight
        
        model: VarietyModel {
            id: varietyModel
            cropId: crop_id
        }
        
        delegate: SettingsVarietyDelegate {
            width: parent.width
            onRefresh: varietyModel.refresh()
            firstColumnWidth: pane.firstColumnWidth
            secondColumnWidth: pane.secondColumnWidth
        }
    }
    
    Button {
        visible: showVarietiesButton.checked
        id: addVarietyButton
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        flat: true
        text: qsTr("Add variety")
        onClicked: addVarietyDialog.open();
        
        AddVarietyDialog {
            id: addVarietyDialog
            onAccepted: {
                if (seedCompanyId > 0)
                    Variety.add({"variety" : varietyName,
                                    "crop_id" : model.crop_id,
                                    "seed_company_id" : seedCompanyId});
                else
                    Variety.add({"variety" : varietyName,
                                    "crop_id" : model.crop_id});
                
                varietyModel.refresh();
            }
        }
    }
}
