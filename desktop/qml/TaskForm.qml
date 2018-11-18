/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Flickable {
    Column {
        anchors.fill: parent
        spacing: 16
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            MyComboBox {
                id: typeField
                editable: false
                Layout.fillWidth: true
                model: TaskTypeModel {
                    id: taskTypeModel

                }
                textRole: "type"
                onAccepted: if (find(editText) === -1)
                                 model.append({text: editText})
            }

            MyComboBox {
                id: methodField
                editable: false
                Layout.fillWidth: true
                model: TaskMethodModel {
                    id: taskMethodModel

                }
                textRole: "method"
                onAccepted: if (find(editText) === -1)
                                 model.append({text: editText})
            }

            MyComboBox {
                id: implementField
                editable: false
                Layout.fillWidth: true
//                model: TaskImplementModel {
//                    id: taskImplementModel

//                }
//                textRole: "implement"
                onAccepted: if (find(editText) === -1)
                                 model.append({text: editText})
            }

            Row {
                id: rowLayout
                width: parent.width
                RadioButton {
                    id: plantingRadioButton
                    checked: true
                    text: qsTr("Plantings")
                }
                RadioButton {
                    id: locationRadioButton
                    text: qsTr("Locations")
                }
            }

            Rectangle {
                visible: plantingRadioButton.checked
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 4
                border.color: Material.color(Material.Grey)
                Column {
                    anchors {
                        fill: parent
                        leftMargin: 8
                        rightMargin: leftMargin
                    }
//            PlantingList {
//                implicitHeight: 200
//                width: 180
//                height: 200
//                Layout.fillWidth: true
//            }
                }
            }


            MyComboBox {
                id: locationField
                visible: locationRadioButton.checked
                Layout.fillWidth: true
                model: ["A", "B", "C"]
            }
        }
    }
}
