/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Dialog {
    id: dialog

    property int season
    property int year
    property int plantingId: -1
    property alias cropId: plantingFormHeader.cropId
    property int quantity: Number(quantityField.text)
    property alias dateString: datePicker.isoDateString
    property alias time: laborTimeField.text
    property var selectedIdList: plantingList.selectedIdList()
    property alias showOnlyHarvested: harvestCheckBox.checked

    property bool formAccepted: cropId > 0 && quantityField.acceptableInput && selectedIdList.length
    property int harvestId: -1
    property var harvestValueMap: Harvest.mapFromId("harvest_view", harvestId)
    property int harvestTypeId: Number(harvestValueMap['harvest_type_id'])
    property string mode: "add"

    signal harvestAdded()
    signal harvestUpdated()

    onCropIdChanged: {
        if (!plantingList.count && showOnlyHarvested && harvestSettings.showAllPlantingIfNoneInWindow)
            harvestCheckBox.checked = false;
    }

    function clearForm() {
        quantityField.reset();
        datePicker.calendarDate = new Date();
        laborTimeField.text = "00:00";
        laborTimeField.manuallyModified = false;
        harvestCheckBox.checked = true;
        plantingList.reset();
        plantingFormHeader.reset();
    }

    function setFormValues(val) {
        Units.setFieldValue(quantityField, val['quantity']);
        Units.setFieldValue(datePicker, val['date']);
        Units.setFieldValue(laborTimeField, val['time']);
        plantingList.selectedIds[val['planting_id']] = true
        plantingList.selectedIdsChanged();
    }

    function create() {
        mode = "add";
        clearForm();
        plantingFormHeader.refresh();
        plantingList.refresh();

        dialog.open()
    }

    function edit(harvestId) {
        mode = "edit";
        dialog.harvestId = harvestId;

        clearForm();

        setFormValues(harvestValueMap);
        dialog.open();

        var cropId = harvestValueMap["crop_id"];
        var cropName = Planting.cropName(harvestValueMap["planting_id"]);
        plantingFormHeader.cropField.selectedId = cropId;
        plantingFormHeader.cropField.text = cropName;

        quantityField.forceActiveFocus();
    }

    function addHarvest() {
        var qty = Number(quantity/selectedIdList.length)
        for (var i = 0; i < selectedIdList.length; i++) {
            Harvest.add({ "date": datePicker.isoDateString,
                          "time": laborTimeField.text,
                          "quantity": qty,
                          "planting_id": selectedIdList[i] })
        }
        harvestAdded();
    }

    function updateHarvest() {
        Harvest.update(harvestId, { "date": datePicker.isoDateString,
                                    "time": laborTimeField.text,
                                    "quantity": quantity })
        harvestUpdated();
    }

    onAccepted: {
        if (mode === "add")
            addHarvest();
        else
            updateHarvest();
    }

    onOpened: {
        if (mode === "add")
            plantingFormHeader.cropField.forceActiveFocus();
    }

    focus: true
    title: mode === "add" ? qsTr("Add Harvest") : qsTr("Edit Harvest")
    padding: Units.mediumSpacing
    implicitWidth: mainColumn.implicitWidth + 2*padding
    implicitHeight: mainColumn.implicitHeight + header.height + footer.height + 2*padding

    Settings {
        id: harvestSettings
        category: "Harvest"
        property bool showAllPlantingIfNoneInWindow
    }

    Shortcut {
        sequences: ["Ctrl+Enter", "Ctrl+Return"]
        enabled: dialog.visible
        context: Qt.ApplicationShortcut
        onActivated: if (formAccepted) accept();
    }

    header: PlantingFormHeader {
        id: plantingFormHeader
        showAddItem: false
        showYieldAndRevenue: false
        mode: dialog.mode
        onCropSelected: quantityField.forceActiveFocus()
    }

    footer: AddEditDialogFooter {
        applyEnabled: dialog.formAccepted
        mode: dialog.mode
    }

    ColumnLayout {
        id: mainColumn
        implicitHeight: 300
        spacing: Units.smallSpacing
        enabled: cropId > 0

        RowLayout {
            Layout.fillWidth:  true
            spacing: Units.formSpacing

            MyTextField {
                id: quantityField
                labelText: qsTr("Quantity")
                suffixText: qsTr("kg")
                floatingLabel: true
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator {
                    bottom: 0
                    top: 999
                }

                Layout.preferredWidth: 80
                Layout.fillWidth: true

                Keys.onReturnPressed: if (formAccepted) dialog.accept();
                Keys.onEnterPressed: if (formAccepted) dialog.accept();
            }

            DatePicker {
                id: datePicker
                labelText: qsTr("Date")
                floatingLabel: true
                calendarDate: new Date()

                Layout.minimumWidth: 120
                Layout.fillWidth: true

                Keys.onReturnPressed: if (formAccepted) dialog.accept();
                Keys.onEnterPressed: if (formAccepted) dialog.accept();
            }

            TimeEdit {
                id: laborTimeField
                labelText: qsTr("Labor Time")
                Layout.fillWidth: true

                Keys.onReturnPressed: if (formAccepted) dialog.accept();
                Keys.onEnterPressed: if (formAccepted) dialog.accept();
            }
        }

        ColumnLayout {
            spacing: 0

            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
                height: Units.rowHeight

                Layout.fillWidth: true

                CheckBox {
                    id: headerCheckbox
                    width: parent.height
                    tristate: true
                    checkState: (plantingList.count && plantingList.checks === plantingList.count)
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

                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    ToolTip.visible: hovered
                    ToolTip.text: checkState == Qt.Checked ? qsTr("Unselect all plantings")
                                                           : qsTr("Select all plantings")
                }

                SearchField {
                    id: plantingSearchField
                    width: parent.width
                    Layout.fillWidth: true
                }

                CheckBox {
                    id: harvestCheckBox
                    text: qsTr("Current")
                    checked: true
                    ToolTip.visible: hovered
                    ToolTip.text: checked ? qsTr("Show only currently harvested plantings for date")
                                          : qsTr("Show all plantings")
                }
            }

            PlantingList {
                id: plantingList
                enabled: mode === "add"
                implicitHeight: 300
                year: dialog.year
                season: dialog.season
                week: datePicker.week
                filterString: plantingSearchField.text
                width: parent.widh
                cropId: plantingFormHeader.cropId
                showActivePlantings: false
                showOnlyHarvested: harvestCheckBox.checked

                Layout.minimumHeight: 30
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
