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

Pane {
    id: pane

    property int firstColumnWidth: 200
    property int secondColumnWidth: 150

    signal close();

    Material.elevation: 2
    Material.background: "white"
    padding: 0

    RowLayout {
        id: rowLayout
        spacing: Units.smallSpacing
        width: parent.width

        ToolButton {
            id: drawerButton
            text: "\ue5c4"
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: pane.close()
            Layout.leftMargin: Units.formSpacing
        }

        Label {
            id: familyLabel
            text: qsTr("Families and crops")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeSubheading
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Add family")
            flat: true
            Material.foreground: Material.accent
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

        }

        Button {
            text: qsTr("Add crop")
            flat: true
            Material.foreground: Material.accent
            onClicked: addCropDialog.open();
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Units.formSpacing

            AddCropDialog {
                id: addCropDialog
            }
        }
    }

    ListView {
        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: Units.smallSpacing
        model: FamilyModel { id: familyModel }
        delegate: familyDelegate
    }

    Component {
        id: familyDelegate
        Column {
            width: parent.width

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

                        TextCheckBox {
                            id: headerCheckbox
                            text: family
                            selectionMode: false
                            color: model.color
                            Layout.preferredWidth: Units.rowHeight * 0.8
                            round: true
                            MouseArea {
                                anchors.fill: parent
                            }
                            Layout.leftMargin: Units.mediumSpacing
                        }

                        TextInput {
                            text: family
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.minimumWidth: pane.firstColumnWidth
                            onEditingFinished: {
                                Family.update(family_id, {"family": text})
                                familyModel.refresh();
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
                                    familyModel.refresh();
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
                }
            }
        }

    }
}
