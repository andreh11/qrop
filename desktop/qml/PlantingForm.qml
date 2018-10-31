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
import QtCharts 2.0

import io.croplan.components 1.0
import "date.js" as MDate

Flickable {
    id: control
    focus: true

    property bool accepted: varietyField.acceptableInput

    property bool directSeeded: directSeedRadio.checked
    property bool transplantRaised: greenhouseRadio.checked
    property bool transplantBought: boughtRadio.checked
    property alias cropField: cropField

    property int plantingType: directSeedRadio.checked ? 1 : (greenhouseRadio.checked ? 2 : 3)
    readonly property int dtm: Number(plantingType === 1 ? sowDtmField.text :
                                                           plantingDtmField.text)
    readonly property int dtt: plantingType === 2 ? Number(greenhouseGrowTimeField.text) : 0
    readonly property int harvestWindow: Number(harvestWindowField.text)
    readonly property string sowingDate:
        plantingType === 1 ? fieldSowingDateField.isoDateString :
                             (plantingType === 2 ? greenhouseStartDateField.isoDateString :
                                                   fieldPlantingDateField.isoDateString)
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
    readonly property int seedsPerCell: Number(seedsPerCellField.text)
    readonly property int seedsPerGram: Number(seedsPerGramField.text)
    readonly property int greenhouseEstimatedLoss: Number(greenhouseEstimatedLossField.text)
    readonly property int seedsQuantity: seedsNeeded() / seedsPerGram
    readonly property int plantsToStart: flatSize * flatsNumber()

    readonly property double yieldPerBedMeter: Number(yieldPerBedMeterField.text)
    readonly property double averagePrice: Number(averagePriceField.text)

    property var selectedKeywords: []

    property variant values: {
        "variety_id": varietyModel.rowId(varietyField.currentIndex),
                "planting_type": plantingType,
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
                "plants_needed": plantsNeeded(),
                "estimated_gh_loss" : greenhouseEstimatedLoss,
                "plants_to_start": plantsToStart,
                "seeds_per_hole": seedsPerCell,
                "seeds_per_gram": seedsPerGram,
                "seeds_number": seedsNeeded(),
                "seeds_quantity": seedsQuantity,
                "keyword_ids": keywordsIdList(),
                "unit_id": unitModel.rowId(unitCombo.currentIndex),
                "yield_per_bed_meter": yieldPerBedMeter,
                "average_price": averagePrice
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
            to.calendarDate = from.calendarDate
        else
            to.calendarDate = MDate.addDays(from.calendarDate,
                                            Number(length.text) * direction)
    }

    function plantsNeeded() {
        if (inRowSpacing === 0)
            return 0;
        return plantingAmount / inRowSpacing * 100 * rowsPerBed
    }

    function seedsNeeded() {
        switch (plantingType) {
        case 1: // DS
            return plantsNeeded() * (1 + seedsExtraPercentage / 100);
        case 2: // TP, raised
            return  plantsToStart * seedsPerCell * (1 + seedsExtraPercentage / 100);
        default: // TP, bought
            return 0;
        }
    }

    function flatsNumber() {
        if (control.flatSize < 1)
            return 0;

        return (plantsNeeded() / flatSize) / (1.0 - greenhouseEstimatedLoss/100);
    }

    contentWidth: width
    contentHeight: mainColumn.height
    flickableDirection: Flickable.VerticalFlick
    Material.background: "white"

    CropModel {
        id: cropModel
    }

    Column {
        id: mainColumn
        width: parent.width
        spacing: 8

        ColumnLayout {
            width: parent.width
            spacing: 8

            MyComboBox {
                id: cropField
                labelText: qsTr("Crop")
                focus: true
                Layout.fillWidth: true
                Layout.topMargin: largeDisplay ? 8 : 0 // avoid clipping of floatingLabel
                model: cropModel
                textRole: "crop"
                editable: false
                showAddItem: true
                addItemText: qsTr("Add Crop")

                onAddItemClicked: addCropDialog.open()
                onCurrentIndexChanged: varietyField.currentIndex = 0
                onActivated: {
                    varietyField.forceActiveFocus()
                    varietyField.popup.open();
                }

                AddCropDialog {
                    id: addCropDialog
                    onAccepted: {
                        Crop.add({"crop" : cropName,
                                  "family_id" : familyId,
                                  "color" : color});
                        cropModel.refresh();
                        cropField.currentIndex = cropField.find(cropName);
                        varietyField.forceActiveFocus();
                        addVarietyDialog.open();
                    }
                }
            }

            MyComboBox {
                id: varietyField
                labelText: qsTr("Variety")
                Layout.fillWidth: true
                editable: false
                showAddItem: true
                addItemText: qsTr("Add Variety")
                model: VarietyModel {
                    id: varietyModel
                    cropId: cropModel.rowId(cropField.currentIndex)
                }
                textRole: "variety"

                onAddItemClicked: addVarietyDialog.open();
                onActivated: plantingAmountField.forceActiveFocus()

                AddVarietyDialog {
                    id: addVarietyDialog
                    onAccepted: {
                        Variety.add({"variety" : varietyName, "crop_id" : varietyModel.cropId});
                        varietyModel.refresh();
                        varietyField.currentIndex = varietyField.find(varietyName);
                        plantingAmountField.forceActiveFocus()
                    }
                }
            }
        }

        FormGroupBox {
            id: plantingAmountBox
            width: parent.width
            title: qsTr("Amounts")

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
                        inputMask: "9000"
                        Layout.fillWidth: true
                        suffixText: qsTr("bed m")
                    }

                    MyTextField {
                        id: inRowSpacingField
                        floatingLabel: true
                        labelText: qsTr("Spacing")
                        inputMethodHints: Qt.ImhDigitsOnly
                        inputMask: "900"
                        Layout.fillWidth: true
                        suffixText: qsTr("cm")
                    }

                    MyTextField {
                        id: rowsPerBedField
                        floatingLabel: true
                        labelText: qsTr("Rows")
                        inputMethodHints: Qt.ImhDigitsOnly
                        inputMask: "90"
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: Units.mediumSpacing
                    MyTextField {
                        id: successionsField
                        text: "1"
                        inputMethodHints: Qt.ImhDigitsOnly
                        inputMask: "90"
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
                        inputMask: successions > 1 ?  "90" : ""
                        labelText: qsTr("Weeks between")
                        Layout.fillWidth: true
                    }
                }
            }
        }

        FormGroupBox {
            width: parent.width
            title: qsTr("Planting Type")
            Flow {
                id: plantingTypeLayout
                anchors.fill: parent
                spacing: 8

                ChoiceChip {
                    id: directSeedRadio
                    text: qsTr("Direct seed")
                    checked: true
                    autoExclusive: true
                }

                ChoiceChip {
                    id: greenhouseRadio
                    text: qsTr("Transplant, raised")
                    autoExclusive: true
                }

                ChoiceChip {
                    id: boughtRadio
                    text: qsTr("Transplant, bought")
                    autoExclusive: true
                }
            }
        }

        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates") + " " + (successions > 1 ? qsTr("(first succession)") : "")
            width: parent.width

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: 16
                columnSpacing: 16

                DatePicker {
                    id: fieldSowingDateField
                    visible: directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field Sowing")

                    onEditingFinished: updateDateField(fieldSowingDateField,
                                                       sowDtmField,
                                                       firstHarvestDateField, 1)
                }

                MyTextField {
                    id: sowDtmField
                    visible: fieldSowingDateField.visible
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "900"
                    text: "1"
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Days to maturity")

                    onTextChanged: updateDateField(fieldSowingDateField,
                                                   sowDtmField,
                                                   firstHarvestDateField, 1)
                }

                DatePicker {
                    id: greenhouseStartDateField
                    visible: greenhouseRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Greenhouse start date")

                    onEditingFinished: updateDateField(
                                           greenhouseStartDateField,
                                           greenhouseGrowTimeField,
                                           fieldPlantingDateField, 1)
                }

                MyTextField {
                    id: greenhouseGrowTimeField
                    visible: greenhouseStartDateField.visible
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "900"
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Greenhouse duration")
                    suffixText: qsTr("days")

                    onTextChanged: updateDateField(greenhouseStartDateField,
                                                   greenhouseGrowTimeField,
                                                   fieldPlantingDateField, 1)
                }

                DatePicker {
                    id: fieldPlantingDateField
                    visible: !directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Field planting")

                    onEditingFinished: updateDateField(
                                           fieldPlantingDateField,
                                           greenhouseGrowTimeField,
                                           greenhouseStartDateField, -1)
                    onCalendarDateChanged: updateDateField(
                                               fieldPlantingDateField,
                                               plantingDtmField,
                                               firstHarvestDateField, 1)
                }

                MyTextField {
                    id: plantingDtmField
                    visible: fieldPlantingDateField.visible
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "900"
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Days to maturity")
                    suffixText: qsTr("days")

                    onTextChanged: updateDateField(fieldPlantingDateField,
                                                   plantingDtmField,
                                                   firstHarvestDateField, 1)
                }

                DatePicker {
                    id: firstHarvestDateField
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("First harvest")

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
                    id: harvestWindowField
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "900"
                    Layout.fillWidth: true
                    floatingLabel: true
                    labelText: qsTr("Harvest window")
                    helperText: text === "" ? "" : qsTr(
                                                  "Last: ") + MDate.addDays(
                                                  firstHarvestDateField.calendarDate,
                                                  Number(text)).toLocaleString(
                                                  Qt.locale(), "ddd d MMM yyyy")
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
                spacing: 16
                MyTextField {
                    id: flatSizeField
                    labelText: qsTr("Flat type")
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "9000"
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: seedsPerCellField
                    labelText: qsTr("Seeds per cell")
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    maximumLength: 10
                    text: "1"
                    floatingLabel: true
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: greenhouseEstimatedLossField
                    text: "0"
                    labelText: qsTr("Estimated loss")
                    suffixText: qsTr("%")
                    helperText: qsTr("%n flat(s)", "", flatsNumber())
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    Layout.fillWidth: true
                }
            }
        }

        FormGroupBox {
            id: seedBox
            title: qsTr("Seeds")
            visible: !boughtRadio.checked
            RowLayout {
                width: parent.width
                spacing: 16
                MyTextField {
                    id: seedsNeededField
                    floatingLabel: true
                    inputMethodHints: Qt.ImhDigitsOnly
                    //                    inputMask: "900000"
                    labelText: qsTr("Needed")
                    Layout.fillWidth: true
                    text: Math.round(seedsNeeded())
                }

                MyTextField {
                    id: seedsExtraPercentageField
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    floatingLabel: true
                    labelText: qsTr("Extra %")
                    suffixText: "%"
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: seedsPerGramField
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90000"
                    text: "0"
                    floatingLabel: true
                    labelText: qsTr("Per gram")
                    errorText: qsTr("Enter a quantity!")
                    helperText: qsTr("%n g", "", seedsQuantity)
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
                    id: unitCombo
                    labelText: qsTr("Unit")
                    editable: true
                    model: UnitModel {
                        id: unitModel
                    }
                    textRole: "unit"
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: yieldPerBedMeterField
                    labelText: qsTr("Yield/bed m")
                    inputMethodHints: Qt.ImhDigitsOnly
                    suffixText: unitCombo.currentText
                    //                    inputMask: "900000"
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: averagePriceField
                    labelText: qsTr("Price/") + unitCombo.currentText
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    floatingLabel: true
                    suffixText: "€"
                    Layout.fillWidth: true
                }
            }
        }

        FormGroupBox {
            width: parent.width
            title: qsTr("Keywords")
            Flow {
                id: keywordsView
                clip: true
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: KeywordModel { }
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

                ChoiceChip {
                    id: addKeywordChip
                    text: "\ue234"
                    flat: true
                    font.family: "Material Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                }
            }
        }
    }

}
