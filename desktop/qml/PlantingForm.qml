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
import Qt.labs.platform 1.0 as Lab
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Flickable {
    id: control
    property int currentYear

    // Initialisation mode ensures that no duration field is modified.
    property bool initMode: false

    property bool coherentDates: dtt >= 0 && dtm >= 0 && harvestWindow >= 0
    property bool accepted: (mode === "edit" || varietyField.currentIndex >= 0) && coherentDates

    property int locationViewWidth: locationView.treeViewWidth
    property alias durationMode: durationCheckBox.checked

    property string mode: "add" // add or edit
    property bool chooseLocationMode: false
    readonly property int varietyId: varietyModel.rowId(varietyField.currentIndex)
    property alias inGreenhouse: inGreenhouseCheckBox.checked
    property bool directSeeded: directSeedRadio.checked
    property bool transplantRaised: greenhouseRadio.checked
    property bool transplantBought: boughtRadio.checked
    property alias varietyField: varietyField
    property alias addVarietyDialog: addVarietyDialog
    property alias cropId: varietyModel.cropId

    property int plantingType: directSeedRadio.checked ? 1 : (greenhouseRadio.checked ? 2 : 3)
    readonly property int dtm: Number(plantingType === 1 ? sowDtmField.text : plantingDtmField.text)
    readonly property int dtt: plantingType === 2 ? Number(greenhouseGrowTimeField.text) : 0
    readonly property int harvestWindow: Number(harvestWindowField.text)
    readonly property string sowingDate: {
        if (plantingType === 1)
            fieldSowingDateField.isoDateString;
        else if (plantingType === 2)
            greenhouseStartDateField.isoDateString;
        else
            fieldPlantingDateField.isoDateString;
    }
    readonly property string plantingDate: plantingType === 1 ? fieldSowingDateField.calendarDate :
                                                                fieldPlantingDateField.calendarDate
    readonly property string plantingDateString: plantingType === 1 ? fieldSowingDateField.isoDateString :
                                                                fieldPlantingDateField.isoDateString
    readonly property string begHarvestDate: begHarvestDateField.isoDateString
    readonly property string endHarvestDate: Qt.formatDate(MDate.addDays(
                                                               begHarvestDateField.calendarDate,
                                                               harvestWindow),
                                                           "yyyy-MM-dd")

    property int successions: Number(successionsField.text)
    property int weeksBetween: Number(timeBetweenSuccessionsField.text)

    readonly property int traySize: Number(traySizeField.text)
    readonly property int plantingLength: {
        if (plantingAmountField.text) {
            if (settings.useStandardBedLength)
                return Number.fromLocaleString(Qt.locale(), plantingAmountField.text)
                        * settings.standardBedLength
            else
                return Number.fromLocaleString(Qt.locale(), plantingAmountField.text)
        } else {
            return 0;
        }
    }
    readonly property int inRowSpacing: Number(inRowSpacingField.text)
    readonly property int rowsPerBed: Number(rowsPerBedField.text)
    readonly property int seedsExtraPercentage: Number(seedsExtraPercentageField.text)
    readonly property int seedsPerHole: Number(seedsPerHoleField.text)
    readonly property int seedsPerGram: Number(seedsPerGramField.text)
    readonly property real seedsNeeded: {
        if (plantingType === 1) // DS
            plantsNeeded * (1 + seedsExtraPercentage / 100);
        else if (plantingType === 2) // TP, raised
            plantsToStart * seedsPerHole * (1 + seedsExtraPercentage / 100);
        else // TP, bought
            0;
    }
    readonly property int greenhouseEstimatedLoss: Number(greenhouseEstimatedLossField.text)
    readonly property real seedsQuantity: seedsPerGram ? toPrecision(seedsNeeded / seedsPerGram, 2)
                                                       : 0
    readonly property int plantsToStart: traySize * traysNumber
    readonly property int plantsNeeded: inRowSpacing === 0
                                        ? 0
                                        : plantingLength / inRowSpacing * 100 * rowsPerBed
    readonly property real traysNumber: control.traySize < 1
                                        ? 0
                                        : toPrecision((plantsNeeded / traySize)
                                                      / (1.0 - greenhouseEstimatedLoss/100), 2);

    readonly property alias unitText: unitField.currentText
    readonly property real yieldPerBedMeter: yieldPerBedMeterField.text ? Number.fromLocaleString(Qt.locale(), yieldPerBedMeterField.text) : 0
    readonly property real estimatedYield: plantingLength * yieldPerBedMeter
    readonly property real averagePrice: averagePriceField.text ? Number.fromLocaleString(Qt.locale(), averagePriceField.text) : 0
    readonly property real estimatedRevenue: averagePrice * estimatedYield

    property var selectedLocationIds: locationView.selectedLocationIds()
    property alias assignedLengthMap: locationView.assignedIdMap // locationId -> length
    readonly property int assignedLength: locationView.assignedLength()
    readonly property int remainingLength: plantingLength - assignedLength

    property var selectedKeywords: [] // List of ids of the selected keywords.
    readonly property var values: {
        "variety_id": varietyId,
        "planting_type": plantingType,
        "in_greenhouse": inGreenhouse ? 1 : 0, // SQLite doesn't have bool type
        "planting_date": plantingDateString,
        "dtm": dtm,
        "dtt": dtt,
        "harvest_window": harvestWindow,
        "length": plantingLength,
        "rows": rowsPerBed,
        "spacing_plants": inRowSpacing,
        "plants_needed": plantsNeeded,
        "estimated_gh_loss" : greenhouseEstimatedLoss,
        "plants_to_start": plantsToStart,
        "seeds_per_hole": seedsPerHole,
        "seeds_per_gram": seedsPerGram,
        "seeds_number": seedsNeeded,
        "seeds_quantity": seedsQuantity,
        "seeds_percentage": seedsExtraPercentage,
        "keyword_ids": keywordsIdList(),
        "unit_id": unitModel.rowId(unitField.currentIndex),
        "yield_per_bed_meter": yieldPerBedMeter,
        "average_price": averagePrice,
        "tray_size" : traySize,
        "trays_to_start": traysNumber
    }

    readonly property var widgetField: [
        [varietyField, "variety_id", varietyId],
        [directSeedRadio, "planting_type", plantingType],
        [greenhouseRadio, "planting_type", plantingType],
        [boughtRadio, "planting_type", plantingType],
        [inGreenhouseCheckBox, "in_greenhouse", inGreenhouse],
        [fieldSowingDateField, "planting_date", plantingDateString],
        [fieldPlantingDateField, "planting_date", plantingDateString],
        [sowDtmField, "dtm", dtm],
        [plantingDtmField, "dtm", dtm],
        [greenhouseGrowTimeField, "dtt", dtt],
        [harvestWindowField, "harvest_window", harvestWindow],
        [plantingAmountField, "length", plantingLength],
        [rowsPerBedField, "rows", rowsPerBed],
        [inRowSpacingField, "spacing_plants", inRowSpacing],
        // TODO: plants needed
        [greenhouseEstimatedLossField, "estimated_gh_loss", greenhouseEstimatedLoss],
        [seedsPerHoleField, "seeds_per_hole", seedsPerHole],
        [seedsPerGramField, "seeds_per_gram", seedsPerGram],
        [seedsNeededField, "seeds_number", seedsNeeded],
        [seedsExtraPercentageField, "seeds_percentage", seedsExtraPercentage],
        // TODO: keywords
        [unitField, "unit_id", unitModel.rowId(unitField.currentIndex)],
        [yieldPerBedMeterField, "yield_per_bed_meter", yieldPerBedMeter],
        [averagePriceField, "average_price", averagePrice],
        [traySizeField, "tray_size", traySize],
        // TODO: trays to start
    ]

    function editedValues() {
        var map = {};

        for (var i in widgetField) {
            var widget = widgetField[i][0]
            var name = widgetField[i][1]
            var value = widgetField[i][2]

            if ((widget instanceof MyTextField && widget.manuallyModified)
                    || (widget instanceof ChoiceChip && widget.manuallyModified)
                    || (widget instanceof MyComboBox && widget.manuallyModified)
                    || (widget instanceof CheckBox && widget.manuallyModified)
                    || (widget instanceof DatePicker && widget.modified)) {
                map[name] = value;
            }
        }
        return map;
    }

    function clearAll() {
        // Refresh models
        varietyModel.refresh();
        locationView.refresh();
        keywordModel.refresh();
        unitModel.refresh();

        // Reset fields
        varietyField.reset();
        locationView.clearSelection();
        chooseLocationMode = false;

        inGreenhouseCheckBox.checked = false;
        inGreenhouseCheckBox.manuallyModified = false;

        plantingAmountField.reset();
        inRowSpacingField.reset();
        rowsPerBedField.reset();
        successionsField.reset();
        successionsField.text = "1";
        directSeedRadio.reset();
        directSeedRadio.checked = true;
        boughtRadio.reset();
        greenhouseRadio.reset();

        durationCheckBox.checked = plantingSettings.durationsByDefault
        fieldPlantingDateField.clear();
        fieldSowingDateField.clear();
        greenhouseStartDateField.clear();
        begHarvestDateField.clear();
        endHarvestDateField.clear();

        fieldSowingDateField.modified = false;
        fieldPlantingDateField.modified = false;

        sowDtmField.reset();
        greenhouseGrowTimeField.reset();
        plantingDtmField.reset();
        harvestWindowField.reset();

        traySizeField.reset();
        seedsPerHoleField.reset();
        greenhouseEstimatedLossField.reset();
        seedsNeededField.reset();
        seedsExtraPercentageField.reset();
        seedsExtraPercentageField.text = "0"
        seedsPerGramField.reset();

        unitField.reset();
        yieldPerBedMeterField.reset();
        averagePriceField.reset();
        selectedKeywords = []
    }

    // Set item to value only if it has not been manually modified by
    // the user. To do this, we use the manuallyModified boolean value.
    function setFieldValue(item, value) {
        if (!value || item.manuallyModified)
            return;

        if (item instanceof MyTextField)
            item.text = value;
        else if (item instanceof CheckBox || item instanceof ChoiceChip)
            item.checked = value;
        else if (item instanceof MyComboBox)
            item.setRowId(value);
    }

    function setFormValues(val) {
        if (mode === "edit" && 'variety_id' in val) {
            var varietyId = Number(val['variety_id'])
            cropId = Variety.cropId(varietyId)
            varietyModel.refresh();
            varietyField.setRowId(varietyId);
        }

        if (mode === "edit") {
            if (settings.useStandardBedLength) {
                var bedLength = Number(settings.standardBedLength)
                setFieldValue(plantingAmountField, val['length']/bedLength);
            } else {
                setFieldValue(plantingAmountField, val['length']);
            }
        }
        setFieldValue(inRowSpacingField, val['spacing_plants']);
        setFieldValue(rowsPerBedField, val['rows']);
        setFieldValue(inGreenhouseCheckBox, val['in_greenhouse'] === 1 ? true : false);

        var pDate = mode === "add" ? new Date()
                                   : Date.fromLocaleString(Qt.locale(), val["planting_date"],
                                                           "yyyy-MM-dd");

        initMode = true
        setFieldValue(harvestWindowField, val['harvest_window']);
        switch (val['planting_type']) {
        case 1:
            setFieldValue(directSeedRadio, true);
            if ('dtm' in val)
                setFieldValue(sowDtmField, val['dtm']);

            fieldSowingDateField.calendarDate = pDate;
            if ('dtm' in val)
                updateFromFieldSowingDate();
            fieldSowingDateField.modified = false;
            break;
        case 2:
            setFieldValue(greenhouseRadio, true);
            if ('dtt' in val) setFieldValue(greenhouseGrowTimeField, val['dtt']);
            if ('dtm' in val) setFieldValue(plantingDtmField, val['dtm']);

            fieldPlantingDateField.calendarDate = pDate
            if ('dtt' in val && 'dtm' in val)
                updateFromFieldPlantingDate(true, true);
            fieldPlantingDateField.modified = false;
            break;
        case 3:
            setFieldValue(boughtRadio, true);
            if ('dtm' in val) setFieldValue(plantingDtmField, val['dtm']);

            fieldPlantingDateField.calendarDate = pDate;
            if ('dtm' in val)
                updateFromFieldPlantingDate(true, true);
            updateFromFieldPlantingDate(true, true);
            fieldPlantingDateField.modified = false;
        }
        initMode = false

        setFieldValue(traySizeField, val['tray_size']);
        setFieldValue(seedsPerHoleField, val['seeds_per_hole']);
        setFieldValue(greenhouseEstimatedLossField, val['estimated_gh_loss']);
        setFieldValue(seedsExtraPercentageField, val['seeds_percentage']);
        setFieldValue(seedsPerGramField, val['seeds_per_gram']);
        setFieldValue(unitField, Number(val['unit_id']));
        setFieldValue(yieldPerBedMeterField, val['yield_per_bed_meter']);
        setFieldValue(averagePriceField, val['average_price']);

        if ('planting_id' in val) {
            var keywordIdList = Keyword.keywordIdList(val['planting_id'])
            for (var i in keywordIdList)
                selectedKeywords[keywordIdList[i]] = true;
            selectedKeywordsChanged();
        }
    }

    function preFillForm(from) {
        var val = Planting.lastValues(varietyId, cropId, plantingType, inGreenhouse);
        delete val[from];
        if (val.length)
            setFormValues(val);
    }

    function keywordsIdList() {
        var idList = [];
        for (var id in selectedKeywords)
            if (selectedKeywords[id])
                idList.push(id);
        return idList;
    }

    function toPrecision(x, decimals) {
        return Math.round(x * (10^decimals)) / (10^decimals);
    }

    // From https://stackoverflow.com/a/45947980
    function ensureItemVisible(item) {
        if (!item.activeFocus)
            return;

        var ypos = item.mapToItem(contentItem, 0, 0).y
        var ext = item.height + ypos
        if (ypos < contentY // begins before
                || ypos > contentY + height // begins after
                || ext < contentY // ends before
                || ext > contentY + height) { // ends after
            // don't exceed bounds
            contentY = Math.max(0, Math.min(ypos - height + item.height, contentHeight - height))
        }
     }

    /**
     * Duration functions
     **/
    function updateDuration(picker1, picker2, durationField) {
        if (initMode)
            return;

        durationField.text = MDate.daysTo(picker1.calendarDate, picker2.calendarDate)
        durationField.manuallyModified = true

        // Mark sow/planting field date as modified (for proper update).
        if (directSeeded)
            fieldSowingDateField.modified = true
        else
            fieldPlantingDateField.modified = true
    }

    function updateGHDuration() {
        updateDuration(greenhouseStartDateField, fieldPlantingDateField, greenhouseGrowTimeField);
    }

    function updateDtm() {
        if (directSeeded) {
            updateDuration(fieldSowingDateField, begHarvestDateField, sowDtmField);
        }  else {
            updateDuration(fieldPlantingDateField, begHarvestDateField, plantingDtmField);
        }
    }

    function updateHarvestWindow() {
        updateDuration(begHarvestDateField, endHarvestDateField, harvestWindowField);
    }

    // Date functions

    // The following functions should be called only when prefilling the form
    // or when the user edit the relevant field.

    // direction = 1 means days forward, -1 means backward
    function updateDateField(from, duration, to, direction) {
        if (duration.text === "")
            to.calendarDate = from.calendarDate;
        else
            to.calendarDate = MDate.addDays(from.calendarDate,
                                            Number(duration.text) * direction);
    }

    function updateFromFieldSowingDate() {
        if (!durationMode && !initMode)
            return;
        updateDateField(fieldSowingDateField, sowDtmField, begHarvestDateField, 1);

        updateFromFirstHarvestDate(true, false);
    }

    function updateFromGreenhouseStartDate() {
        if (!durationMode && !initMode)
            return;
        updateDateField(greenhouseStartDateField, greenhouseGrowTimeField, fieldPlantingDateField, 1)
        if (!initMode)
            fieldPlantingDateField.modified = true

        updateFromFieldPlantingDate(true, false);
    }

    function updateFromFieldPlantingDate(forward, backward) {
        if (!durationMode && !initMode)
            return;

        if (plantingType === 2 && backward)
            updateDateField(fieldPlantingDateField, greenhouseGrowTimeField,
                            greenhouseStartDateField, -1)
        if (forward) {
            updateDateField(fieldPlantingDateField, plantingDtmField, begHarvestDateField, 1);
            updateFromFirstHarvestDate(true, false);
        }
    }

    function updateFromFirstHarvestDate(forward, backward) {
        if (!durationMode && !initMode)
            return;

        if (forward)
            updateDateField(begHarvestDateField, harvestWindowField, endHarvestDateField, 1);

        if (!backward)
            return;

        if (directSeeded) {
            updateDateField(begHarvestDateField, sowDtmField, fieldSowingDateField, -1);
            if (!initMode)
                fieldSowingDateField.modified = true;
        }  else {
            updateDateField(begHarvestDateField, plantingDtmField, fieldPlantingDateField, -1);
            if (!initMode)
                fieldPlantingDateField.modified = true;
            updateFromFieldPlantingDate(false, true);
        }
    }

    function updateFromEndHarvestDate() {
        if (!durationMode && !initMode)
            return;

        updateDateField(endHarvestDateField, harvestWindowField, begHarvestDateField, -1);
        updateFromFirstHarvestDate(false, true);
    }

    focus: true
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Material.background: "white"
    contentHeight: mainColumn.height
    contentWidth: width

    onCropIdChanged: varietyField.reset()
    onVarietyIdChanged: if (mode === "add") preFillForm("variety_id")
    onPlantingTypeChanged: if (mode === "add") preFillForm("planting_type")
    onInGreenhouseChanged: if (mode === "add") preFillForm("in_greenhouse")

    Settings {
        id: settings
        property bool useStandardBedLength
        property int standardBedLength
    }

    Settings {
        id: plantingSettings
        category: "PlantingsPane"
        property bool durationsByDefault
        property bool showDurationFields
    }

    VarietyModel { id: varietyModel }
    KeywordModel { id: keywordModel }

    Column {
        id: mainColumn
        width: control.width
        spacing: Units.smallSpacing

        RowLayout {
            width: parent.width
            spacing: Units.mediumSpacing
            visible: !chooseLocationMode

            MyComboBox {
                id: varietyField
                labelText: qsTr("Variety")
                Layout.fillWidth: true
                editable: false
                showAddItem: true
                addItemText: qsTr("Add Variety")
                model: varietyModel
                textRole: "variety"

                onAddItemClicked: addVarietyDialog.open()
                onActivated: plantingAmountField.forceActiveFocus()
                onActiveFocusChanged: ensureItemVisible(varietyField)

                AddVarietyDialog {
                    id: addVarietyDialog
                    onAccepted: {
                        if (seedCompanyId > 0)
                            Variety.add({"variety" : varietyName,
                                         "crop_id" : varietyModel.cropId,
                                         "seed_company_id" : seedCompanyId});
                        else
                            Variety.add({"variety" : varietyName,
                                         "crop_id" : varietyModel.cropId});

                        varietyModel.refresh();
                        varietyField.currentIndex = varietyField.find(varietyName);
                        plantingAmountField.forceActiveFocus()
                    }
                }
            }

            CheckBox {
                id: inGreenhouseCheckBox
                property bool manuallyModified
                text: qsTr("In Greenhouse")
                onPressed: manuallyModified = true
            }
        }

        FormGroupBox {
            id: plantingAmountBox
            width: parent.width

            ColumnLayout {
                width: parent.width
                spacing: Units.mediumSpacing

                RowLayout {
                    spacing: Units.mediumSpacing

                    MyTextField {
                        id: plantingAmountField
                        focus: true
                        labelText: settings.useStandardBedLength ? qsTr("# of beds") : qsTr("Length")
                        suffixText: settings.useStandardBedLength ? qsTr("bed", "", Number(text)) : qsTr("bed m")
                        floatingLabel: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator:  QropDoubleValidator {
                            bottom: 0;
                            decimals: settings.useStandardBedLength ? 2 : 0
                            top: 999;
                            notation: DoubleValidator.StandardNotation
                        }
                        Layout.fillWidth: true
                        onActiveFocusChanged: ensureItemVisible(plantingAmountField)
                    }

                    MyTextField {
                        id: inRowSpacingField
                        labelText: qsTr("Spacing")
                        suffixText: qsTr("cm")
                        floatingLabel: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 999 }
                        Layout.fillWidth: true
                        onActiveFocusChanged: ensureItemVisible(inRowSpacingField)
                    }

                    MyTextField {
                        id: rowsPerBedField
                        floatingLabel: true
                        labelText: qsTr("Rows")
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 99 }
                        Layout.fillWidth: true
                        onActiveFocusChanged: ensureItemVisible(rowsPerBedField)
                    }
                }

                RowLayout {
                    spacing: Units.mediumSpacing
                    visible: mode === "add" && !chooseLocationMode
                    Layout.fillWidth: true

                    MyTextField {
                        id: successionsField
                        text: "1"
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 99 }
                        floatingLabel: true
                        labelText: qsTr("Successions")
                        Layout.fillWidth: true
                        onActiveFocusChanged: if (!activeFocus && text === "") text = "1"
                    }

                    MyTextField {
                        id: timeBetweenSuccessionsField
                        enabled: successions > 1
                        text: successions > 1 ? "1" : qsTr("Single planting")
                        floatingLabel: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 99 }
                        labelText: qsTr("Weeks between")
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Flow {
            id: plantingTypeLayout
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            spacing: Units.smallSpacing
            visible: !chooseLocationMode

            ChoiceChip {
                id: directSeedRadio
                text: qsTr("Direct seed")
                checked: true
                autoExclusive: true
                onActiveFocusChanged: ensureItemVisible(directSeedRadio)
            }

            ChoiceChip {
                id: greenhouseRadio
                text: qsTr("Transplant, raised")
                autoExclusive: true
                onActiveFocusChanged: ensureItemVisible(greenhouseRadio)
            }

            ChoiceChip {
                id: boughtRadio
                text: qsTr("Transplant, bought")
                autoExclusive: true
                onActiveFocusChanged: ensureItemVisible(boughtRadio)
            }
        }

        FormGroupBox {
            id: durationsBox
            title: qsTr("Durations")
            width: parent.width
            visible: plantingSettings.showDurationFields

            label: CheckBox {
                id: durationCheckBox
                text: parent.title
                checked: plantingSettings.durationsByDefault
                onActiveFocusChanged: ensureItemVisible(durationCheckBox)
            }

            GridLayout {
                width: parent.width
                columns: smallDisplay ? 1 : (plantingType === 2 ? 4 : 3)
                rowSpacing: 16
                columnSpacing: 16

                MyTextField {
                    id: sowDtmField
                    visible: fieldSowingDateField.visible && !chooseLocationMode

                    enabled: durationMode
                    text: "1"
                    labelText: qsTr("Days to maturity")
                    suffixText: qsTr("days")
                    floatingLabel: true

                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true

                    onTextChanged: updateFromFieldSowingDate()
                    onActiveFocusChanged: ensureItemVisible(sowDtmField)
                }

                MyTextField {
                    id: greenhouseGrowTimeField
                    visible: greenhouseStartDateField.visible && !chooseLocationMode
                    enabled: durationMode
                    text: "1"
                    labelText: qsTr("Greenhouse duration")
                    suffixText: qsTr("days")
                    floatingLabel: true

                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true

                    onTextChanged: updateFromGreenhouseStartDate();
                    onActiveFocusChanged: ensureItemVisible(greenhouseGrowTimeField)
                }

                MyTextField {
                    id: plantingDtmField
                    visible: fieldPlantingDateField.visible && !chooseLocationMode
                    enabled: durationMode
                    text: "1"
                    labelText: qsTr("Days to maturity")
                    suffixText: qsTr("days")
                    floatingLabel: true

                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true

                    onTextChanged: updateFromFieldPlantingDate(true, true)
                    onActiveFocusChanged: ensureItemVisible(plantingDtmField)
                }

                MyTextField {
                    id: harvestWindowField
                    visible: !chooseLocationMode
                    enabled: durationMode
                    text: "1"
                    labelText: qsTr("Harvest window")
                    suffixText: qsTr("days")
                    floatingLabel: true

                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true

                    onTextChanged: updateFromFirstHarvestDate(true, true);
                    onActiveFocusChanged: ensureItemVisible(harvestWindowField)
                }
            }
        }

        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates") + " " + (successions > 1 ? qsTr("(first succession)") : "")
            width: parent.width

            GridLayout {
                width: parent.width
                columns: smallDisplay ? 1 : (plantingType === 2 ? 4 : 3)
                rowSpacing: 16
                columnSpacing: 16

                DatePicker {
                    id: fieldSowingDateField

                    property bool modified: false

                    visible: directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field Sowing")
                    currentYear: control.currentYear

                    onEditingFinished: {
                        if (durationMode)
                            updateFromFieldSowingDate();
                        else
                            updateDtm();
                    }
                    onActiveFocusChanged: ensureItemVisible(fieldSowingDateField)
                    onCalendarDateChanged: modified = true
                }

                DatePicker {
                    id: greenhouseStartDateField
                    visible: greenhouseRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Greenhouse start date")
                    currentYear: control.currentYear
                    onActiveFocusChanged: ensureItemVisible(greenhouseStartDateField)
                    onEditingFinished: {
                        if (durationMode)
                            updateFromGreenhouseStartDate()
                        else
                            updateGHDuration();
                    }
                }

                DatePicker {
                    id: fieldPlantingDateField

                    property bool modified: false

                    visible: !directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field planting")
                    currentYear: control.currentYear

                    onActiveFocusChanged: ensureItemVisible(fieldPlantingDateField)
                    onEditingFinished: {
                        if (durationMode)
                            updateFromFieldPlantingDate(true, true)
                        else {
                            if (plantingType == 2)
                                updateGHDuration();
                            updateDtm();
                        }
                    }
                }

                DatePicker {
                    id: begHarvestDateField
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("First harvest")
                    currentYear: control.currentYear

                    onActiveFocusChanged: ensureItemVisible(begHarvestDateField)
                    onEditingFinished: {
                        if (durationMode) {
                            updateFromFirstHarvestDate(true, true)
                        } else {
                            updateDtm();
                            updateHarvestWindow();
                        }
                    }
                }

                DatePicker {
                    id: endHarvestDateField
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Last harvest")
                    currentYear: control.currentYear

                    onActiveFocusChanged: ensureItemVisible(endHarvestDateField)
                    onEditingFinished: {
                        if (durationMode)
                            updateFromEndHarvestDate()
                        else
                            updateHarvestWindow();
                    }
                }
            }
        }

        FormGroupBox {
            id: locationGroupBox
            visible: successions === 1 && mode === "add"

            Behavior on height { NumberAnimation { duration: 1000 } }

            Column {
                id: locationColumn
                anchors.fill: parent

                Button {
                    id: locationButton
                    flat: true
                    visible: !chooseLocationMode
                    width: parent.width
                    text: {
                        if (locationView.selectedLocationIds().length ===  0) {
                            return qsTr("Choose locations");
                        }
                        return qsTr("Locations: %1").arg(Location.fullName(locationView.selectedLocationIds()));
                    }
                    onClicked: chooseLocationMode = true
                    onActiveFocusChanged: ensureItemVisible(locationButton)
                }

                RowLayout {
                    visible: chooseLocationMode
                    width: parent.width

                    Label {
                        Layout.fillWidth: true
                        text: settings.useStandardBedLength
                              ? qsTr("Remaining beds: %L1").arg(remainingLength/settings.standardBedLength)
                              : qsTr("Remaining length: %L1 m", "", remainingLength).arg(remainingLength)
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    Button {
                        text: qsTr("Unassign all beds")
                        onClicked: locationView.clearSelection()
                        flat: true
                    }

                    Button {
                        text: qsTr("Close")
                        flat: true
                        onClicked: chooseLocationMode = false
                        Material.foreground: Material.accent
                    }
                }

                LocationView {
                    id: locationView
                    visible: chooseLocationMode

                    property date plantingDate: plantingType === 1 ? fieldSowingDateField.calendarDate
                                                                   : fieldPlantingDateField.calendarDate
                    season: MDate.season(plantingDate)
                    year: MDate.seasonYear(plantingDate)
                    width: parent.width
                    height: 400
                    plantingEditMode: true

                    editedPlantingLength: plantingLength
                    editedPlantingPlantingDate: plantingDate
                    editedPlantingEndHarvestDate: MDate.addDays(begHarvestDateField.calendarDate,
                                                                harvestWindow)
                    onAddPlantingLength: {
                        if (settings.useStandardBedLength)
                            plantingAmountField.text = Number(plantingAmountField.text) + (length/settings.standardBedLength)
                        else
                            plantingAmountField.text = plantingLength + length
                    }
                }
            }
        }

        FormGroupBox {
            id: greenhouseBox
            title: qsTr("Greenhouse details")
            visible: greenhouseRadio.checked && !chooseLocationMode
            RowLayout {
                width: parent.width
                spacing: Units.formSpacing
                MyTextField {
                    id: traySizeField
                    labelText: qsTr("Flat type")
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(traySizeField)
                }

                MyTextField {
                    id: greenhouseEstimatedLossField
                    text: "0"
                    labelText: qsTr("Estimated loss")
                    suffixText: qsTr("%")
                    helperText: qsTr("%L1 flat(s)", "", traysNumber).arg(traysNumber)
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: 99 }
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(greenhouseEstimatedLossField)
                }
            }
        }

        FormGroupBox {
            id: seedBox
            title: qsTr("Seeds")
            visible: !boughtRadio.checked && !chooseLocationMode
            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: 16
                columnSpacing: 16

                MyTextField {
                    id: seedsPerHoleField
                    labelText: qsTr("Seeds per hole")
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 99 }
                    maximumLength: 10
                    text: "1"
                    floatingLabel: true
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(seedsPerHoleField)
                }

                MyTextField {
                    id: seedsNeededField
                    floatingLabel: true
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: 999999}
                    //                    inputMask: "900000"
                    labelText: qsTr("Needed")
                    Layout.fillWidth: true
                    text: "%L1".arg(Math.round(seedsNeeded))
                    onActiveFocusChanged: ensureItemVisible(seedsNeededField)
                }

                MyTextField {
                    id: seedsExtraPercentageField
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 99 }
                    floatingLabel: true
                    labelText: qsTr("Extra %")
                    suffixText: "%"
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(seedsExtraPercentageField)
                }

                MyTextField {
                    id: seedsPerGramField
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: 99999 }
                    text: "0"
                    floatingLabel: true
                    labelText: qsTr("Per gram")
                    errorText: qsTr("Enter a quantity!")
                    helperText: qsTr("%L1 g", "", seedsQuantity).arg(seedsQuantity)
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(seedsPerGramField)
                }
            }
        }

        FormGroupBox {
            width: parent.width
            title: qsTr("Harvest & revenue rate")
            visible: !chooseLocationMode

            RowLayout {
                width: parent.width
                spacing: 16

                MyComboBox {
                    id: unitField
                    labelText: qsTr("Unit")
                    currentIndex: find("kg")
                    addItemText: qsTr("Add Unit")
                    showAddItem: true
                    model: UnitModel {
                        id: unitModel
                    }
                    textRole: "abbreviation"
                    Layout.fillWidth: true

                    onAddItemClicked: addUnitDialog.open();
                    onActiveFocusChanged: ensureItemVisible(unitField)
                    //                    onActivated: plantingAmountField.forceActiveFocus()

                    AddUnitDialog {
                        id: addUnitDialog
                        onAccepted: {
                            Unit.add({"fullname" : unitName,
                                         "abbreviation": unitAbbreviation});
                            unitModel.refresh();
                            unitField.currentIndex = unitField.find(unitAbbreviation);
                            //                            plantingAmountField.forceActiveFocus()
                        }
                    }
                }

                MyTextField {
                    id: yieldPerBedMeterField
                    labelText: qsTr("Yield/bed m")
                    inputMethodHints: Qt.ImhDigitsOnly
                    suffixText: unitField.currentText
                    //                    inputMask: "900000"
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(yieldPerBedMeterField)
                }

                MyTextField {
                    id: averagePriceField
                    labelText: qsTr("Price/") + unitField.currentText
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: QropDoubleValidator {
                        bottom: 0
                        decimals: 2
                        top: 999
                        notation: DoubleValidator.StandardNotation
                    }
                    floatingLabel: true
                    suffixText: "€"
                    Layout.fillWidth: true
                    onActiveFocusChanged: ensureItemVisible(averagePriceField)
                }
            }
        }

        Flow {
            id: keywordsView
            clip: true
            width: parent.width
            spacing: 8
            visible: !chooseLocationMode

            Repeater {
                model: keywordModel
                width: parent.width

                ChoiceChip {
                    id: keywordChoiceChip
                    text: keyword
                    checked: keyword_id in selectedKeywords && selectedKeywords[keyword_id]

                    onActiveFocusChanged: ensureItemVisible(keywordChoiceChip)
                    onClicked: {
                        selectedKeywords[keyword_id] = !selectedKeywords[keyword_id]
                        selectedKeywordsChanged();
                    }
                }
            }
        }
    }
}
