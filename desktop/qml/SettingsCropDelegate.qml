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

// TODO: refactor

import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Column {
    id: control

    property int firstColumnWidth
    property int secondColumnWidth

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
                height: Units.listSingleLineHeight
                spacing: Units.formSpacing

                TextDisk {
                    id: headerCheckbox
                    text: model.crop
                    color: model.color
                    Layout.leftMargin: Units.mediumSpacing
                    onClicked: colorPickerDialog.open()

                    Dialog {
                        id: colorPickerDialog
                        width: 400
                        height: 400
                        margins: 0
                        ColorPicker {
                            anchors.fill: parent
                            onNewColorSelected:{
                                colorPickerDialog.close();
                                print("Edit Crop color"+crop_id+": "+color);
                                cppFamily.updateCropColor(cropModel.sourceRow(index), family_id, crop_id, model.color, color);

//                                Crop.update(model.crop_id, {"color": color});
//                                refresh();
                            }
                        }
                    }
                }

                EditableLabel {
                    id: editableLabel
                    text: model.crop
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.maximumWidth: Layout.minimumWidth
                    Layout.fillHeight: true
                    onEditingFinished: {
                        print("Edit Crop name"+crop_id+": "+color);
                        cppFamily.updateCropName(cropModel.sourceRow(index), family_id, crop_id, crop, text);

//                        Crop.update(model.crop_id, {"crop": text});
//                        refresh();
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
                        margins: 0
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
                    text: "\ue313"
                    rotation: checked ? 180 : 0
                    font.family: "Material Icons"
                    font.pixelSize: 22
//                    ToolTip.text: checked ? qsTr("Hide varieties") : qsTr("Show varieties")
//                    ToolTip.visible: hovered
//                    ToolTip.delay: 199
                }
            }
        }
    }

    ListView {
        id: varietyView
        spacing: 0
        visible: showVarietiesButton.checked
        width: parent.width
        height: contentHeight

//        onVisibleChanged: if (visible) varietyModel.refresh();

        model: VarietyProxyModel {
            id: varietyModel
            cropId: crop_id
        }

        ButtonGroup {
            id: buttonGroupL
        }

        delegate: SettingsVarietyDelegate {
            width: parent.width
//            onRefresh: { varietyModel.refreshRow(index); varietyModel.resetFilter(); }
            firstColumnWidth: control.firstColumnWidth
            secondColumnWidth: control.secondColumnWidth
            buttonGroup: buttonGroupL
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
            margins: 0
            onAccepted: cppFamily.addNewVariety(crop_id, varietyName, seedCompanyId)
        }
    }
}
