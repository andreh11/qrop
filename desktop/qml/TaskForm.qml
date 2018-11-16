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
                id: taskField
                editable: true
                Layout.fillWidth: true
                model: ListModel {
                    id: model
                    ListElement { text: "Cultivation \& Tillage"}
                    ListElement { text: "Fertilize \& Amend"}
                    ListElement { text: "Greenhouse Activaty"}
                    ListElement { text: "Irrigate"}
                    ListElement { text: "Maintenance"}
                    ListElement { text: "Pest \& Disease"}
                    ListElement { text: "Prune"}
                    ListElement { text: "Row Cover \& Mulch"}
                    ListElement { text: "Thin"}
                    ListElement { text: "Treillis"}
                    ListElement { text: "Weed"}
                }

                onAccepted: if (find(editText) === -1)
                                 model.append({text: editText})
            }

            MyTextField {
                id: varietyField
                floatingLabel: true
                placeholderText: qsTr("Method")
                Layout.fillWidth: true
            }
            
            MyTextField {
                id: familyField
                floatingLabel: true
                placeholderText: qsTr("Description")
                Layout.fillWidth: true
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
