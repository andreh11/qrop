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
    property int taskTypeId: -1

    property int taskMethodId: taskMethodModel.rowId(methodField.currentIndex)
    property int taskImplementId: taskImplementModel.rowId(implementField.currentIndex)

    readonly property bool accepted: true
    readonly property alias dueDateString: dueDatepicker.isoDateString
    readonly property int duration: Number(durationField.text)
    readonly property alias laborTimeString: laborTimeField.text
    readonly property alias plantingTask: plantingRadioButton.checked
    readonly property alias locationTask: locationRadioButton.checked
    readonly property alias plantingIdList: plantingList.plantingIdList
    onPlantingIdListChanged: console.log(plantingIdList)

    readonly property var values: {
        "assigned_date": dueDateString,
        "completed_date": "",
        "duration": duration,
        "labor_time": laborTimeString,
        "task_type_id": taskTypeId,
        "task_method_id": taskMethodId,
        "task_implement_id": taskImplementId,
        "planting_ids": plantingIdList
    }

    function reset() {
        plantingList.reset();
    }

    focus: true
    contentWidth: width
//    contentHeight: mainColumn.height
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Material.background: "white"

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
//        width: parent.width
//        height: parent.height
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

        FormGroupBox {
            id: datesGroupBox
            width: parent.width
            Layout.fillWidth: true

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
        }

        Row {
            id: radioRow
            width: parent.width
            spacing: Units.smallSpacing
            Layout.fillWidth: true

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

        FormGroupBox {
            Layout.fillHeight: true
            Layout.fillWidth: true
            topPadding: Units.smallSpacing
            bottomPadding: Units.smallSpacing

            ColumnLayout {
                anchors.fill: parent
                visible: plantingRadioButton.checked
                spacing: 0
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
                    implicitHeight: 30
                    Layout.minimumHeight: 30
                    Layout.minimumWidth: 100
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
