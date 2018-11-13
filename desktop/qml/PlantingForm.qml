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

import io.croplan.components 1.0
import "date.js" as MDate

Flickable {
    id: control
    property int currentYear
    property bool accepted: varietyField.acceptableInput

    readonly property int varietyId: varietyModel.rowId(varietyField.currentIndex)
    property alias inGreenhouse: inGreenhouseCheckBox.checked
    property bool directSeeded: directSeedRadio.checked
    property bool transplantRaised: greenhouseRadio.checked
    property bool transplantBought: boughtRadio.checked
    property alias varietyField: varietyField
    property alias addVarietyDialog: addVarietyDialog
    property alias cropId: varietyModel.cropId

    property int plantingType: directSeedRadio.checked ? 1 : (greenhouseRadio.checked ? 2 : 3)
    readonly property int dtm: Number(plantingType === 1 ? sowDtmField.text :
                                                           plantingDtmField.text)
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
    readonly property string plantingDate: plantingType === 1 ? fieldSowingDateField.isoDateString :
                                                                fieldPlantingDateField.isoDateString
    readonly property string begHarvestDate: firstHarvestDateField.isoDateString
    readonly property string endHarvestDate: Qt.formatDate(MDate.addDays(
                                                               firstHarvestDateField.calendarDate,
                                                               harvestWindow),
                                                           "yyyy-MM-dd")

    property int successions: Number(successionsField.text)
    property int weeksBetween: Number(timeBetweenSuccessionsField.text)

    readonly property int flatSize: Number(flatSizeField.text)
    readonly property int plantingAmount: Number(plantingAmountField.text)
    readonly property int inRowSpacing: Number(inRowSpacingField.text)
    readonly property int rowsPerBed: Number(rowsPerBedField.text)
    readonly property int seedsExtraPercentage: Number(seedsExtraPercentageField.text)
    readonly property int seedsPerCell: Number(seedsPerHoleField.text)
    readonly property int seedsPerGram: Number(seedsPerGramField.text)
    readonly property real seedsNeeded: {
        if (plantingType === 1) // DS
            plantsNeeded * (1 + seedsExtraPercentage / 100);
        else if (plantingType === 2) // TP, raised
            plantsToStart * seedsPerCell * (1 + seedsExtraPercentage / 100);
        else // TP, bought
            0;
    }
    readonly property int greenhouseEstimatedLoss: Number(greenhouseEstimatedLossField.text)
    readonly property real seedsQuantity: seedsPerGram ? toPrecision(seedsNeeded / seedsPerGram, 2) : 0
    readonly property int plantsToStart: flatSize * flatsNumber
    readonly property int plantsNeeded: inRowSpacing === 0
                                        ? 0
                                        : plantingAmount / inRowSpacing * 100 * rowsPerBed
    readonly property real flatsNumber: control.flatSize < 1
                                        ? 0
                                        : toPrecision((plantsNeeded / flatSize)
                                                      / (1.0 - greenhouseEstimatedLoss/100), 2);

    readonly property alias unitText: unitField.currentText
    readonly property real yieldPerBedMeter: Number(yieldPerBedMeterField.text)
    readonly property real estimatedYield: plantingAmount * yieldPerBedMeter
    readonly property real averagePrice: {
        if (averagePriceField.acceptableInput)
            Number.fromLocaleString(Qt.locale(), averagePriceField.text);
        else
            0;
    }
    readonly property real estimatedRevenue: averagePrice * estimatedYield

    property var selectedKeywords: []
    property variant values: {
        "variety_id": varietyId,
        "planting_type": plantingType,
        "in_greenhouse": inGreenhouse ? 1 : 0, // SQLite doesn't have bool type
        "sowing_date": sowingDate,
        "planting_date": plantingDate,
        "beg_harvest_date": begHarvestDate,
        "end_harvest_date": endHarvestDate,
        "dtm": dtm,
        "dtt": dtt,
        "harvest_window": harvestWindow,
        "length": plantingAmount ,
        "rows": rowsPerBed,
        "spacing_plants": inRowSpacing,
        "plants_needed": plantsNeeded,
        "estimated_gh_loss" : greenhouseEstimatedLoss,
        "plants_to_start": plantsToStart,
        "seeds_per_hole": seedsPerCell,
        "seeds_per_gram": seedsPerGram,
        "seeds_number": seedsNeeded,
        "seeds_quantity": seedsQuantity,
        "seeds_percentage": seedsExtraPercentage,
        "keyword_ids": keywordsIdList(),
        "unit_id": unitModel.rowId(unitField.currentIndex),
        "yield_per_bed_meter": yieldPerBedMeter,
        "average_price": averagePrice,
        "tray_size" : flatSize,
        "trays_to_start": flatsNumber
    }

    function clearAll() {
        varietyField.currentIndex = -1;
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
        sowDtmField.reset();
        greenhouseGrowTimeField.reset();
        plantingDtmField.reset();
        harvestWindowField.reset();
        flatSizeField.reset();
        seedsPerHoleField.reset();
        greenhouseEstimatedLossField.reset();
        seedsNeededField.reset();
        seedsExtraPercentageField.reset();
        seedsExtraPercentageField.text = "0"
        seedsPerGramField.reset();
        unitField.reset();
        yieldPerBedMeterField.reset();
        averagePriceField.reset();
    }

    // Set item to value only if item has not been manually modified by
    // the user. To do this, we use the manuallyModified boolean value.
    function setFieldValue(item, value) {
//        console.log(item, value, item.manuallyModified)
        if (!item.manuallyModified) {
            if (item instanceof MyTextField)
                item.text = value;
            else if (item instanceof CheckBox || item instanceof ChoiceChip)
                item.checked = value;
            else if (item instanceof MyComboBox)
                item.setRowId(value);
        }
    }

    function setFormValues(val, editMode) {
        if (editMode && 'variety_id' in val) {
            var varietyId = Number(val['variety_id'])
            cropId = Variety.cropId(varietyId)
            console.log("varietyId", varietyId, "cropId", cropId)
            varietyModel.refresh();
            varietyField.setRowId(varietyId);
        }

        setFieldValue(inRowSpacingField, val['spacing_plants']);
        setFieldValue(rowsPerBedField, val['rows']);
        setFieldValue(inGreenhouseCheckBox, val['in_greenhouse'] === 1 ? true : false);

        switch (val['planting_type']) {
        case 1:
            setFieldValue(directSeedRadio, true);
            setFieldValue(sowDtmField, val['dtm']);
            break;
        case 2:
            setFieldValue(greenhouseRadio, true);
            setFieldValue(greenhouseGrowTimeField, val['dtt']);
            setFieldValue(plantingDtmField, val['dtm']);
            break;
        default:
            setFieldValue(boughtRadio, true);
            setFieldValue(plantingDtmField, val['dtm']);
        }
        setFieldValue(harvestWindowField, val['harvest_window']);

        setFieldValue(flatSizeField, val['tray_size']);
        setFieldValue(seedsPerHoleField, val['seeds_per_hole']);
        setFieldValue(greenhouseEstimatedLossField, val['estimated_gh_loss']);
        setFieldValue(seedsExtraPercentageField, val['seeds_percentage']);
        setFieldValue(seedsPerGramField, val['seeds_per_gram']);
        setFieldValue(unitField, Number(val['unit_id']));
        setFieldValue(yieldPerBedMeterField, val['yield_per_bed_meter']);
        setFieldValue(averagePriceField, val['average_price']);

        // TODO: keywords
    }

    function preFillForm(editMode) {
        var val = Planting.lastValues(varietyId, cropId, plantingType, inGreenhouse);
        if (val.length)
            setFormValues(val, editMode);
    }

    function emitSelectedKeywordsChanged() {
        selectedKeywords = selectedKeywords;
    }

    function keywordsIdList() {
        var idList = [];
        for (var id in selectedKeywords)
            if (selectedKeywords[id])
                idList.push(id);
        return idList;
    }

    function updateDateField(from, length, to, direction) {
        if (length.text === "")
            to.calendarDate = from.calendarDate;
        else
            to.calendarDate = MDate.addDays(from.calendarDate,
                                            Number(length.text) * direction);
    }

    function toPrecision(x, decimals) {
        return Math.round(x * (10^decimals)) / (10^decimals);
    }

    function ensureVisible(focus, y, height) {
        console.log("CALLED", y, height, control.contentY, control.height)
        if (!focus)
            return;
        if (y < control.contentY) {
            control.contentY = y
        } else if ((y+height) > (control.contentY + control.height)) {
            control.contentY = y + height - control.height
        }
    }

    onCropIdChanged: varietyField.currentIndex = -1;
    onVarietyIdChanged: preFillForm(false);
    onPlantingTypeChanged: preFillForm(false);
    onInGreenhouseChanged: preFillForm(false);

    focus: true
    contentWidth: width
    contentHeight: mainColumn.height
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    Material.background: "white"

    KeywordModel {
        id: keywordModel
    }

    Column {
        id: mainColumn
        width: parent.width
        spacing: Units.formSpacing

        RowLayout {
            width: parent.width
            spacing: Units.mediumSpacing
            MyComboBox {
                id: varietyField
                labelText: qsTr("Variety")
                Layout.fillWidth: true
                editable: false
                showAddItem: true
                addItemText: qsTr("Add Variety")
                model: VarietyModel {
                    id: varietyModel
                }
                textRole: "variety"

                onAddItemClicked: addVarietyDialog.open()
                onActivated: plantingAmountField.forceActiveFocus()
                onActiveFocusChanged: ensureVisible(activeFocus, y, height)

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
//            title: qsTr("Amounts")

            ColumnLayout {
                width: parent.width
                spacing: Units.mediumSpacing

                RowLayout {
                    spacing: Units.mediumSpacing

                    MyTextField {
                        id: plantingAmountField
                        floatingLabel: true
                        labelText: qsTr("Length")
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 0; top: 999 }
                        Layout.fillWidth: true
                        suffixText: qsTr("bed m")
                        onActiveFocusChanged: ensureVisible(activeFocus, y, height)
                    }

                    MyTextField {
                        id: inRowSpacingField
                        floatingLabel: true
                        labelText: qsTr("Spacing")
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 999 }
                        Layout.fillWidth: true
                        suffixText: qsTr("cm")
                        onActiveFocusChanged: ensureVisible(activeFocus, y, height)
                    }

                    MyTextField {
                        id: rowsPerBedField
                        floatingLabel: true
                        labelText: qsTr("Rows")
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: IntValidator { bottom: 1; top: 99 }
                        Layout.fillWidth: true
                        onActiveFocusChanged: ensureVisible(activeFocus, y, height)
                    }
                }

                RowLayout {
                    spacing: Units.mediumSpacing

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

//        FormGroupBox {
//            id: plantingTypeBox
//            width: parent.width
//            title: qsTr("Planting Type")
            Flow {
                id: plantingTypeLayout
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                width: parent.width
//                Layout.fillWidth: true
//                anchors.fill: parent
                spacing: 8

                ChoiceChip {
                    id: directSeedRadio
                    text: qsTr("Direct seed")
                    checked: true
                    autoExclusive: true
                    onActiveFocusChanged: ensureVisible(activeFocus, plantingTypeBox.y+height, height)
                }

                ChoiceChip {
                    id: greenhouseRadio
                    text: qsTr("Transplant, raised")
                    autoExclusive: true
                    onActiveFocusChanged: ensureVisible(activeFocus, plantingTypeBox.y+height, height)
                }

                ChoiceChip {
                    id: boughtRadio
                    text: qsTr("Transplant, bought")
                    autoExclusive: true
                    onActiveFocusChanged: ensureVisible(activeFocus, plantingTypeBox.y+height, height)
                }

            }
//        }

        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates") + " " + (successions > 1 ? qsTr("(first succession)") : "")
            width: parent.width

            GridLayout {
                width: parent.width
                columns: smallDisplay ? 1 : (plantingType === 2 ? 3 : 2)
                rowSpacing: 16
                columnSpacing: 16

                DatePicker {
                    id: fieldSowingDateField
                    visible: directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field Sowing")
                    currentYear: control.currentYear

                    onEditingFinished: updateDateField(fieldSowingDateField,
                                                       sowDtmField,
                                                       firstHarvestDateField, 1)
                    onActiveFocusChanged: ensureVisible(activeFocus, plantingsDateBox.y, plantingsDateBox.height)
                }

                DatePicker {
                    id: greenhouseStartDateField
                    visible: greenhouseRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Greenhouse start date")
                    currentYear: control.currentYear

                    onEditingFinished: updateDateField(greenhouseStartDateField,
                                                       greenhouseGrowTimeField,
                                                       fieldPlantingDateField, 1)
                }

                DatePicker {
                    id: fieldPlantingDateField
                    visible: !directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field planting")
                    currentYear: control.currentYear

                    onEditingFinished: updateDateField(fieldPlantingDateField,
                                                       greenhouseGrowTimeField,
                                                       greenhouseStartDateField, -1)
                    onCalendarDateChanged: updateDateField(fieldPlantingDateField,
                                                           plantingDtmField,
                                                           firstHarvestDateField, 1)
                }

                DatePicker {
                    id: firstHarvestDateField
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("First harvest")
                    currentYear: control.currentYear

                    onEditingFinished: {
                        if (directSeeded)
                            updateDateField(firstHarvestDateField, sowDtmField,
                                            fieldSowingDateField, -1)
                        else
                            updateDateField(firstHarvestDateField,
                                            plantingDtmField,
                                            fieldPlantingDateField, -1)
                    }
                }

                MyTextField {
                    id: sowDtmField
                    visible: fieldSowingDateField.visible
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    text: "1"
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Days to maturity")

                    onTextChanged: updateDateField(fieldSowingDateField,
                                                   sowDtmField,
                                                   firstHarvestDateField, 1)
                }


                MyTextField {
                    id: greenhouseGrowTimeField
                    visible: greenhouseStartDateField.visible
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Greenhouse duration")
                    suffixText: qsTr("days")

                    onTextChanged: updateDateField(greenhouseStartDateField,
                                                   greenhouseGrowTimeField,
                                                   fieldPlantingDateField, 1)
                    onActiveFocusChanged: {
//                        if (!activeFocus)
//                            return;
                        console.log("Scrolling...")
                        if (y < control.contentY)
                            control.contentY = control.contentY - y
                        else if (y > control.contentY + control.height)
                            control.contentY = control.contentY + y
                    }
                }


                MyTextField {
                    id: plantingDtmField
                    visible: fieldPlantingDateField.visible
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Days to maturity")
                    suffixText: qsTr("days")

                    onTextChanged: updateDateField(fieldPlantingDateField,
                                                   plantingDtmField,
                                                   firstHarvestDateField, 1)
                }


                MyTextField {
                    id: harvestWindowField
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Harvest window")
                    helperText: text ? NDate.formatDate(endHarvestDate, currentYear) : ""
                    suffixText: qsTr("days")
                }
            }
        }

        FormGroupBox {
            id: greenhouseBox
            title: qsTr("Greenhouse details")
            visible: greenhouseRadio.checked
            RowLayout {
                width: parent.width
                spacing: Units.formSpacing
                MyTextField {
                    id: flatSizeField
                    labelText: qsTr("Flat type")
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 999 }
                    Layout.fillWidth: true
                }

//                MyTextField {
//                    id: seedsPerHoleField
//                    labelText: qsTr("Seeds per hole")
//                    inputMethodHints: Qt.ImhDigitsOnly
//                    validator: IntValidator { bottom: 1; top: 99 }
//                    maximumLength: 10
//                    text: "1"
//                    floatingLabel: true
//                    Layout.fillWidth: true
//                }

                MyTextField {
                    id: greenhouseEstimatedLossField
                    text: "0"
                    labelText: qsTr("Estimated loss")
                    suffixText: qsTr("%")
                    helperText: qsTr("%L1 flat(s)", "", flatsNumber).arg(flatsNumber)
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 0; top: 99 }
                    Layout.fillWidth: true
                }
            }
        }

        FormGroupBox {
            id: seedBox
            title: qsTr("Seeds")
            visible: !boughtRadio.checked
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
                }

                MyTextField {
                    id: seedsExtraPercentageField
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1; top: 99 }
                    floatingLabel: true
                    labelText: qsTr("Extra %")
                    suffixText: "%"
                    Layout.fillWidth: true
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
                }
            }
        }

        FormGroupBox {
            width: parent.width
            title: qsTr("Harvest & revenue rate")

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
                }

                MyTextField {
                    id: averagePriceField
                    labelText: qsTr("Price/") + unitField.currentText
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: TextFieldDoubleValidator {
                        bottom: 0
                        decimals: 2
                        top: 999
                        notation:  DoubleValidator.StandardNotation
                    }
                    floatingLabel: true
                    suffixText: "€"
                    Layout.fillWidth: true
                }
            }
        }

//        FormGroupBox {
//            width: parent.width
//            title: qsTr("Keywords")
            Flow {
                id: keywordsView
                clip: true
                width: parent.width
                spacing: 8

                Repeater {
                    model: keywordModel
                    width: parent.width

                    ChoiceChip {
                        text: keyword
                        checked: keyword_id in selectedKeywords && selectedKeywords[keyword_id]

                        onClicked: {
                            selectedKeywords[keyword_id] = !selectedKeywords[keyword_id]
                            emitSelectedKeywordsChanged();
                        }
                    }
                }

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1.0
                        duration: 200
                    }
                }
            }
        }
    }
//}
