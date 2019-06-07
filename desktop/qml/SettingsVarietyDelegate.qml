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

import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Column {
    property int firstColumnWidth
    property int secondColumnWidth
    property ButtonGroup buttonGroup

    signal refresh()

    Rectangle {
        height: childrenRect.height
        width: parent.width

        MouseArea {
            id: varietyMouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true

            RowLayout {
                id: varietyRow
                height: Units.rowHeight
                width: parent.width
                spacing: Units.formSpacing

                RadioButton {
                    autoExclusive: true
                    Layout.leftMargin: Units.mediumSpacing
                    ButtonGroup.group: buttonGroup
                    onCheckedChanged: Variety.setDefault(model.variety_id, checked)
                    checked: Variety.isDefault(model.variety_id)
                }

                TextInput {
                    text: model.variety
                    color: Qt.rgba(0, 0, 0, 0.7)
                    font.family: "Roboto Regular"
//                    Layout.leftMargin: Units.mediumSpacing + Units.formSpacing + 48
                    maximumLength: 25
                    Layout.maximumWidth: Layout.minimumWidth
                    Layout.minimumWidth: firstColumnWidth

                    onEditingFinished: Variety.update(model.variety_id, {"variety": text})
                }

                // BUG: this shouldb a MyComboBox, but this one seems to buggy; the height
                // of the Popup isn't always correct.
                ComboBox {
                    id: seedCompanyField

                    property int rowId: seed_company_id

                    function setRowId(rowId) {
                        var i = 0;
                        while (model.rowId(i) !== rowId && i < model.rowCount)
                            i++;
                        if (i < model.rowCount)
                            currentIndex = i;
                    }

                    onRowIdChanged: setRowId(rowId)
                    flat: true
                    Layout.minimumWidth: secondColumnWidth
                    model: SeedCompanyModel {
                        id: seedCompanyModel
                    }
                    textRole: "seed_company"

                    onCurrentIndexChanged: {
                        var companyId = seedCompanyModel.rowId(seedCompanyField.currentIndex)
                        Variety.update(variety_id, {"seed_company_id": companyId})
                    }
                }

                Item { height: 1; Layout.fillWidth: true }


                MyToolButton {
                    height: parent.height * 0.8
                    visible: varietyMouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22

                    ToolTip.text: qsTr("Remove variety")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: Units.formSpacing

                    onClicked: confirmVarietyDeleteDialog.open()

                    Dialog {
                        id: confirmVarietyDeleteDialog
                        title: qsTr("Delete %1?").arg(model.variety)
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All plantings will be lost.")
                        }

                        onAccepted: {
                            Variety.remove(model.variety_id)
                            refresh()
                        }

                        onRejected: confirmVarietyDeleteDialog.close()
                    }
                }
            }

        }
    }
}

