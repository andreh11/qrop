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

    property string mode: "add" // add or edit
    property int week
    property int year
    property int taskId
    property var taskValueMap
    property int taskTypeId: -1

    property int taskMethodId: taskMethodModel.rowId(methodField.currentIndex)
    property int taskImplementId: taskImplementModel.rowId(implementField.currentIndex)

    readonly property bool accepted: plantingTask && plantingIdList.length
    readonly property alias dueDateString: dueDatepicker.isoDateString
    readonly property int duration: Number(durationField.text)
    readonly property alias laborTimeString: laborTimeField.text
    readonly property alias plantingTask: plantingRadioButton.checked
    readonly property alias locationTask: locationRadioButton.checked
    readonly property alias plantingIdList: plantingList.plantingIdList
    property string completedDate: ""

    readonly property var values: {
        "assigned_date": dueDateString,
        "completed_date": completedDate,
        "duration": duration,
        "labor_time": laborTimeString,
        "task_type_id": taskTypeId,
        "task_method_id": taskMethodId,
        "task_implement_id": taskImplementId,
        "planting_ids": plantingIdList
    }

    function setFieldValue(item, value) {
        if (!value)
            return;

        if (item instanceof MyTextField)
            item.text = value;
        else if (item instanceof CheckBox || item instanceof ChoiceChip)
            item.checked = value;
        else if (item instanceof MyComboBox)
            item.setRowId(value);
    }

    function setFormValues(val) {
        if ("assigned_date" in val)
            dueDatepicker.calendarDate = Date.fromLocaleString(Qt.locale(), val['assigned_date'],
                                                               "yyyy-MM-dd")
        if ("duration" in val) durationField.text = val["duration"]
        if ("labor_time" in val) laborTimeField.text = val["labor_time"]
        if ("task_method_id" in val) methodField.setRowId(Number(val["task_method_id"]))
        if ("task_implement_id" in val) implementField.setRowId(Number(val["task_implement_id"]))
        if ("plantings" in val) {
            var idList = val["plantings"].split(",")
            for (var i = 0; i < idList.length; i++)
                plantingList.selectedIds[idList[i]] = true
            plantingList.selectedIdsChanged();
        }
    }

    function reset() {
        plantingList.reset();
        methodField.currentIndex = -1;
        implementField.currentIndex = -1;
        dueDatepicker.calendarDate = NDate.dateFromWeekString(control.week);
        durationField.text = "0";
        laborTimeField.text = "00:00";
        plantingRadioButton.checked = true;
        locationRadioButton.checked = false;
    }

    focus: true
    contentWidth: width
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Material.background: "white"

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
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
                    calendarDate: NDate.dateFromWeekString(control.week)
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
                visible: false // Location handling is not implemented yet
                text: qsTr("Locations")
                autoExclusive: true
            }
        }

        FormGroupBox {
            visible: plantingRadioButton.checked
            topPadding: Units.smallSpacing
            bottomPadding: Units.smallSpacing

            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    height: Units.rowHeight
                    Layout.fillWidth: true
                    CheckBox {
                        id: headerCheckbox
                        width: parent.height
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        tristate: true
                        checkState: (plantingList.count && plantingList.checks == plantingList.count)
                                    ? Qt.Checked
                                    : (plantingList.checks > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                        nextCheckState: function () {
                            if (checkState == Qt.Checked) {
                                plantingList.unselectAll()
                                return Qt.Unchecked
                            } else {
                                plantingList.selectAll()
                                return Qt.Checked
                            }
                        }
                        ToolTip.text: checkState == Qt.Checked ? qsTr("Unelect all plantings")
                                                               : qsTr("Select all plantings")
                        ToolTip.visible: hovered
                    }

                    SearchField {
                        id: plantingSearchField
                        width: parent.width
                        Layout.fillWidth: true
                    }

                    CheckBox {
                        id: currentPlantingsCheckbox
                        text: qsTr("Active plantings")
                        checked: true
                        ToolTip.visible: hovered
                        ToolTip.text: checked ? qsTr("Show only active plantings for due date")
                                              : qsTr("Show all plantings")
                    }
                }

                PlantingList {
                    id: plantingList
                    week: dueDatepicker.week
                    year: control.year
                    filterString: plantingSearchField.text
                    width: parent.widh
                    implicitHeight: 30
                    showActivePlantings: currentPlantingsCheckbox.checked

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
