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
    id: control

    property int year
    property bool accepted: true
    property int taskTypeId: -1
    property int taskMethodId: taskMethodModel.rowId(methodField.currentIndex)
    property int taskImplementId: taskImplementModel.rowId(implementField.currentIndex)

    focus: true
    contentWidth: width
    contentHeight: mainColumn.height
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Material.background: "white"

    Column {
        id: mainColumn
        width: parent.width
        spacing: Units.formSpacing

        ColumnLayout {
            width: parent.width
            spacing: 0

            MyComboBox {
                id: methodField
                labelText: qsTr("Method")
                floatingLabel: true
                editable: false
                showAddItem: true
                addItemText: qsTr("Add Method")
                model: TaskMethodModel {
                    id: taskMethodModel
                    typeId: control.taskTypeId
                }
                textRole: "method"

                Layout.fillWidth: true
            }

            MyComboBox {
                id: implementField
                labelText: qsTr("Implement")
                showAddItem: true
                addItemText: qsTr("Add Implement")
                floatingLabel: true
                editable: false

                model: TaskImplementModel {
                    id: taskImplementModel
                    methodId: control.taskMethodId
                }
                textRole: "implement"

                Layout.fillWidth: true
            }
        }

        RowLayout {
            spacing: Units.formSpacing
            width: parent.width

            DatePicker {
                id: dueDatepicker
                labelText: qsTr("Due Date")
                floatingLabel: true
                Layout.minimumWidth: 100
                Layout.fillWidth: true
            }

            MyTextField {
                id: durationField
                text: "0"
                suffixText: qsTr("days")
                labelText: qsTr("Duration")
                floatingLabel: true
                validator: IntValidator { bottom: 0; top: 999 }
                Layout.minimumWidth: 80
                Layout.fillWidth: true
            }

            MyTextField {
                id: laborTimeField
                labelText: qsTr("Labor Time")
                floatingLabel: true
                Layout.minimumWidth: 80
                inputMethodHints: Qt.ImhDigitsOnly
                inputMask: "99:99"
                text: "00:00"
                suffixText: qsTr("h", "Abbreviaton for hour")
                Layout.fillWidth: true
            }
        }

        Row {
            id: radioRow
            width: parent.width
            spacing: Units.smallSpacing

            ChoiceChip {
                id: plantingRadioButton
                autoExclusive: true
                checked: true
                text: qsTr("Plantings")
            }

            ChoiceChip {
                id: locationRadioButton
                text: qsTr("Locations")
                autoExclusive: true
            }
        }

        Rectangle {
            width: parent.width
            height: childrenRect.height
            border.width: 0
            border.color: Material.color(Material.Grey, Material.Shade400)


            ColumnLayout {
                Layout.fillHeight: true
                visible: plantingRadioButton.checked
                width: parent.width
                //            anchors {
                //                fill: parent
                //                leftMargin: 8
                //                rightMargin: leftMargin
                //            }

                SearchField {
                    id: plantingSearchField
                    width: parent.width
                    Layout.fillWidth: true
                }

                PlantingList {
                    id: plantingList
                    filterString: plantingSearchField.text
                    width: parent.widh
                    implicitHeight: 200
                    Layout.minimumHeight: 300
                    Layout.minimumWidth: 200
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
        //            }


        MyComboBox {
            id: locationField
            visible: locationRadioButton.checked
            Layout.fillWidth: true
            model: ["A", "B", "C"]
        }
    }
}
