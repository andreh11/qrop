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

import io.qrop.components 1.0

Flickable {
    id: control

    property string mode: "add" // add or edit
    property int week
    property int year
    property int taskId
    property var taskValueMap
    property int taskTypeId: -1
    property bool sowPlantTask: false
    property bool templateMode: false

    property int taskMethodId: methodField.selectedId
    property int taskImplementId: implementField.selectedId

    readonly property bool accepted: taskTypeId > 0
                                     && (templateMode || (plantingTask && plantingIdList.length)
                                         || (locationTask && locationIdList.length))
    readonly property alias dueDateString: dueDatepicker.isoDateString
    readonly property int duration: Number(durationField.text)
    readonly property alias laborTimeString: laborTimeField.text
    readonly property alias plantingTask: plantingRadioButton.checked
    readonly property alias locationTask: locationRadioButton.checked
    readonly property alias plantingIdList: plantingList.plantingIdList
    readonly property var locationIdList: locationView.selectedLocationIds()
    property string completedDate: ""

    property int taskTemplateId: -1
    property int templateDateType: {
        if (greenhouseSowingButton.checked)
            return 1;
        else if (plantingButton.checked)
            return 0;
        else if (firstHarvestButton.checked)
            return 2;
        else if (lastHarvestButton.checked)
            return 3;
    }
    readonly property int linkDays: Number(daysField.text)


    readonly property var values: {
        "assigned_date": dueDateString,
        "completed_date": completedDate,
        "duration": duration,
        "labor_time": laborTimeString,
        "task_type_id": taskTypeId,
        "task_method_id": taskMethodId,
        "task_implement_id": taskImplementId,
        "planting_ids": plantingTask ? plantingIdList : [],
        "location_ids": locationTask ? locationIdList : []
    }

    readonly property var templateValues: {
        "assigned_date": " ",
        "template_date_type": templateDateType,
        "task_template_id": taskTemplateId,
        "link_days": linkDays * (beforeButton.checked ? -1 : 1),
        "duration": duration,
        "task_type_id": taskTypeId,
        "task_method_id": taskMethodId,
        "task_implement_id": taskImplementId
    }

    function setFormValues(val) {
        if ("assigned_date" in val)
            dueDatepicker.calendarDate =
                    Date.fromLocaleString(Qt.locale(), val['assigned_date'], "yyyy-MM-dd")

        if ("duration" in val)
            durationField.text = val["duration"]

        if ("labor_time" in val)
            laborTimeField.text = val["labor_time"]

        if ("task_method_id" in val) {
            var methodId = Number(val["task_method_id"])
            if (methodId > 0) {
                var methodName = TaskMethod.mapFromId(methodId)["method"];
                methodField.selectedId = methodId;
                methodField.text = methodName;
            }
        }

        if ("task_implement_id" in val) {
            var implementId = Number(val["task_implement_id"])
            if (implementId > 0) {
                var implementName = TaskImplement.mapFromId(implementId)["implement"];
                implementField.selectedId = implementId;
                implementField.text = implementName;
            }
        }

        // Select plantings
        if ("plantings" in val) {
            var idList = val["plantings"].split(",")

            if (val["plantings"])
                plantingRadioButton.checked = true

            for (var i = 0; i < idList.length; i++)
                plantingList.selectedIds[idList[i]] = true

            plantingList.selectedIdsChanged();
        }

        if ("locations" in val) {
            if (val["locations"]) {
                locationRadioButton.checked = true
                var list = val["locations"].split(",")
                locationView.visible = false
                locationView.selectLocationIds(list)
                locationView.visible = true
            }
        }

        if ("link_days" in val) {
            var days = val["link_days"]
            if (days < 0) {
                daysField.text = -days ;
                beforeButton.checked = true;
            } else {
                daysField.text = days ;
                afterButton.checked = true;
            }
        }

        if ("template_date_type" in val) {
            var type = Number(val["template_date_type"]);
            switch (type) {
            case 0:
                plantingButton.checked = true;
                break;
            case 1:
                greenhouseSowingButton.checked = true;
                break;
            case 2:
                firstHarvestButton.checked = true;
                break;
            case 3:
                lastHarvestButton.checked = true;
                break;
            }
        }
    }

    function reset() {
        locationView.refresh();
        taskImplementModel.refresh()
        taskMethodModel.refresh()

        plantingList.reset();
        locationView.clearSelection();
        locationView.collapseAll();

        methodField.reset();
        implementField.reset();

        dueDatepicker.calendarDate = MDate.dateFromWeekString(control.week);
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

    implicitHeight: 200
    Layout.minimumHeight: implicitHeight

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: control.visible && plantingSearchField.visible
        context: Qt.ApplicationShortcut
        onActivated: plantingSearchField.forceActiveFocus()
    }

    Shortcut {
        sequences: ["Ctrl+J"]
        enabled: control.visible && currentPlantingsCheckbox.visible
        context: Qt.ApplicationShortcut
        onActivated: currentPlantingsCheckbox.toggle()
    }

    Shortcut {
        sequence: StandardKey.SelectAll
        enabled: control.visible && plantingList.visible
        context: Qt.ApplicationShortcut
        onActivated: plantingList.selectAll();
    }

    Shortcut {
        sequence: StandardKey.Deselect
        enabled: control.visible && plantingList.visible
        context: Qt.ApplicationShortcut
        onActivated: plantingList.unselectAll();
    }

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        spacing: Units.formSpacing

        ColumnLayout {
            width: parent.width
            spacing: Units.formSpacing
            visible: templateMode || !sowPlantTask

            ComboTextField {
                id: methodField
                enabled: taskTypeId > 0
                labelText: qsTr("Method")
                floatingLabel: true
                showAddItem: true
                addItemText: text ? qsTr('Add new method "%1"').arg(text) : qsTr("Add new method")

                textRole: function (model) { return model.method; }
                idRole: function (model) { return model.task_method_id; }
                model: TaskMethodModel {
                    id: taskMethodModel
                    typeId: control.taskTypeId
                }

                onAddItemClicked: {
                    addMethodDialog.open();
                    addMethodDialog.prefill(text);
                }
                Layout.fillWidth: true

                SimpleAddDialog {
                    id: addMethodDialog
                    validator: RegExpValidator { regExp: /\w[\w\d- ]*/ }
                    title: qsTr("Add Method")

                    onAccepted:  {
                        var id = TaskMethod.add({"method" : text, "task_type_id" : control.taskTypeId});
                        taskMethodModel.refresh();
                        methodField.selectedId = id;
                        methodField.text = text;
                        implementField.forceActiveFocus();
                    }
                    onRejected: methodField.reset();
                }
            }

            ComboTextField {
                id: implementField
                enabled: taskMethodId > 0
                labelText: qsTr("Implement")
                showAddItem: true
                addItemText: text ? qsTr('Add new implement "%1"').arg(text) : qsTr("Add new implement")
                floatingLabel: true
                textRole: function (model) { return model.implement; }
                idRole: function (model) { return model.task_implement_id; }
                model: TaskImplementModel {
                    id: taskImplementModel
                    methodId: control.taskMethodId
                }
                onAddItemClicked: {
                    addImplementDialog.open();
                    addImplementDialog.prefill(text);
                }
                Layout.fillWidth: true

                SimpleAddDialog {
                    id: addImplementDialog
                    validator: RegExpValidator { regExp: /\w[\w\d- ]*/ }
                    title: qsTr("Add Implement")

                    onAccepted:  {
                        var id = TaskImplement.add({"implement" : text,
                                                       "task_method_id" : control.taskMethodId});

                        taskImplementModel.refresh();
                        implementField.selectedId = id;
                        implementField.text = text;
                        dueDatepicker.forceActiveFocus();
                    }
                    onRejected: implementField.reset();
                }
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
                    visible: !templateMode
                    labelText: qsTr("Due Date")
                    floatingLabel: true
                    Layout.minimumWidth: 100
                    Layout.fillWidth: true
                    calendarDate: MDate.dateFromWeekString(control.week)
                }

                MyTextField {
                    id: durationField
                    visible: templateMode || !sowPlantTask
                    text: "0"
                    suffixText: qsTr("days")
                    labelText: qsTr("Duration in field")
                    floatingLabel: true
                    validator: IntValidator { bottom: 0; top: 999 }
                    Layout.minimumWidth: 80
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: laborTimeField
                    visible: !templateMode
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
            visible: !templateMode && !sowPlantTask && mode === "add"
            Layout.fillWidth: true
            Layout.topMargin: -plantingRadioButton.padding * 4
            Layout.bottomMargin: -plantingRadioButton.padding * 4

            RadioButton {
                id: plantingRadioButton
                autoExclusive: true
                checked: true
                text: qsTr("Plantings")
            }

            RadioButton {
                id: locationRadioButton
                text: qsTr("Locations")
                autoExclusive: true
            }
        }

        FormGroupBox {
            visible: !templateMode && plantingRadioButton.checked && !sowPlantTask
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

        FormGroupBox {
            visible: !templateMode && locationRadioButton.checked && !sowPlantTask
            topPadding: Units.smallSpacing
            bottomPadding: Units.smallSpacing

            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: Units.smallSpacing

                LocationView {
                    id: locationView
                    showTimeline: false
                    showHeader: false
                    alwaysShowCheckbox: true
                    year: control.year
                    season: 1
                    showOnlyEmptyLocations: false
                    editMode: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Label {
                    id: selectedLocationLabel
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    text: qsTr("Selected locations: %1").arg(Location.fullName(locationView.selectedLocationIds()))
                    Layout.minimumHeight: 26
                    Layout.fillWidth: true
                }
            }
        }

        FormGroupBox {
            visible: templateMode
            topPadding: Units.smallSpacing
            bottomPadding: Units.smallSpacing

            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: Units.smallSpacing

                MyTextField {
                    id: daysField
                    text: "0"
                    suffixText: qsTr("days")
                    labelText: qsTr("Plan for")
                    floatingLabel: true
                    validator: IntValidator { bottom: 0; top: 999 }
                    Layout.minimumWidth: 80
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        RadioButton {
                            id: beforeButton
                            text: qsTr("Before")
                            checked: true
                        }

                        RadioButton {
                            id: afterButton
                            text: qsTr("After")
                        }

                        VerticalFiller { }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        RadioButton {
                            id: greenhouseSowingButton
                            text: qsTr("Greenhouse sowing")
                            checked: true
                        }

                        RadioButton {
                            id: plantingButton
                            text: qsTr("Sowing/planting")
                        }

                        RadioButton {
                            id: firstHarvestButton
                            text: qsTr("First harvest")
                        }

                        RadioButton {
                            id: lastHarvestButton
                            text: qsTr("Last harvest")
                        }

                        VerticalFiller { }
                    }
                }
            }
        }
    }
}
