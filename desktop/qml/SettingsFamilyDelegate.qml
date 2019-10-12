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

    Behavior on height {
        NumberAnimation { duration: Units.shortDuration }
    }

    Rectangle {
        color: "white"
//        Material.color(Material.Grey, Material.Shade100)
        width: parent.width
        height: Units.listSingleLineHeight

        MouseArea {
            id: familyMouseArea
            anchors.fill: parent
            hoverEnabled: true

            RowLayout {
                anchors.fill: parent
                spacing: Units.formSpacing

                TextDisk {
                    id: headerCheckbox
                    text: ""
                    color: model.color
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    onClicked: colorPickerDialog.open()

                    Dialog {
                        id: colorPickerDialog
                        width: 400
                        height: 400
                        margins: 0
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

                EditableLabel {
                    id: editableLabel
                    text: family
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.maximumWidth: Layout.minimumWidth
                    Layout.fillHeight: true
                    onEditingFinished: {
                        Family.update(family_id, {"family": text})
                        refresh();
                    }
                }

                ComboBox {
                    flat: true
                    model: 10
                    currentIndex: interval
                    Layout.minimumWidth: pane.secondColumnWidth
                    Layout.fillHeight: true
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
                    Layout.fillHeight: true

                    onClicked: confirmFamilyDeleteDialog.open()

                    Dialog {
                        id: confirmFamilyDeleteDialog
                        margins: 0
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
                    Layout.fillHeight: true
                    checkable: true
//                    text: checked ?  "\ue313" : "\ue315"
                    text: "\ue313"
                    rotation: checked ? 180 : 0
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

        onVisibleChanged: if (visible) cropModel.refresh();

        model: CropModel {
            id: cropModel
            familyId: family_id
        }

        delegate: SettingsCropDelegate {
            width: parent.width
            onRefresh: cropModel.refreshRow(index)
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
            margins: 0
            alreadyAssignedFamilyId: true
            onAccepted: {
                var id = Crop.add({"crop" : cropName, "family_id" : family_id, "color" : color});
                Variety.add({ "variety": qsTr("Unknown"), "crop_id": id, "is_default" : 1 });
                cropModel.refresh();
            }
        }
    }

    ThinDivider { width: parent.width }
}
