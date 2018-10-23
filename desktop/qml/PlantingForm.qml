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

    property bool directSeeded: directSeedRadio.checked
    property bool transplantRaised: greenhouseRadio.checked
    property bool transplantBought: boughtRadio.checked
    property alias cropField: cropField

    property int plantingType: directSeedRadio.checked ? 1 : (greenhouseRadio.checked ? 2 : 3)
    readonly property int dtm: parseInt(plantingType === 1 ? sowDtmField.text :
                                                             plantingDtmField.text)
    readonly property int dtt: plantingType === 2 ? parseInt(greenhouseGrowTimeField.text) : 0
    readonly property int harvestWindow: parseInt(harvestWindowField.text)
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

    property variant values: {
        "variety_id": varietyModel.rowId(varietyField.currentIndex),
        "unit_id": unitCombo.currentIndex + 1,
        "planting_type": plantingType,
        "length": parseInt(plantingAmountField.text),
        "spacing_plants": parseInt(inRowSpacingField.text),
        "rows": parseInt(rowsPerBedField.text),
        "sowing_date": sowingDate,
        "planting_date": plantingDate,
        "beg_harvest_date": begHarvestDate,
        "end_harvest_date": endHarvestDate,
        "dtm": dtm,
        "dtt": dtt,
        "harvest_window": harvestWindow
    }

    property int successions: parseInt(successionsField.text)
    property int weeksBetween: parseInt(timeBetweenSuccessionsField.text)

    function updateDateField(from, length, to, direction) {
        if (length.text === "")
            to.calendarDate = from.calendarDate
        else
            to.calendarDate = MDate.addDays(from.calendarDate,
                                            parseInt(length.text) * direction)
    }

    function plantsNeeded() {
        if (plantingAmountField.text === ""
                || inRowSpacingField.text === ""
                || rowsPerBedField.text === "") {
            return 0
        }

        var plantingAmount = parseInt(plantingAmountField.text)
        var inRowSpacing = parseInt(inRowSpacingField.text)
        var rowsPerBed = parseInt(rowsPerBedField.text)
        return plantingAmount / inRowSpacing * 100 * rowsPerBed
    }

    function seedsNeeded() {
        var extraPercentage = 0
        var seeds = 0

        if (seedsExtraPercentageField.text !== "")
            extraPercentage = parseInt(seedsExtraPercentageField.text)

        if (extraPercentage === Number.NaN)
            extraPercentage = 0

        if (directSeedRadio.checked)
            seeds = plantsNeeded() * (1 + extraPercentage / 100)
        else if (greenhouseRadio.checked)
            seeds = transplantsNeeded() * (1 + extraPercentage / 100)
        else
            seeds = plantsNeeded()

        return seeds
    }

    function transplantsNeeded() {
        var flatType = parseInt(flatTypeField.text)
        var seedsPerCell = parseInt(seedsPerCellField.text)
        var estimatedLoss = parseInt(greenhouseEstimatedLossField.text)

        return plantsNeeded() * seedsPerCell / flatType
    }

    contentWidth: width
    contentHeight: mainColumn.height
    flickableDirection: Flickable.VerticalFlick
    Material.background: "white"

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
                model: CropModel {
                    id: cropModel
                }
                textRole: "crop"
                editable: true

                onCurrentIndexChanged: varietyField.currentIndex = 0

                onAccepted: {
                    varietyField.forceActiveFocus();
                }
            }

            MyComboBox {
                id: varietyField
                labelText: qsTr("Variety")
                Layout.fillWidth: true
                editable: true
                model: VarietyModel {
                    id: varietyModel
                    cropId: cropModel.rowId(cropField.currentIndex)
                }
                textRole: "variety"
                onAccepted: unitCombo.forceActiveFocus();
            }


            //            Label {
            //                text: qsTr("Planting type")
            //                font.family: "Roboto Regular"
            //                font.pixelSize: 14
            //            }
            MyComboBox {
                id: unitCombo
                labelText: qsTr("Unit")
                editable: true
                model: UnitModel {
                }
                textRole: "unit"
                Layout.fillWidth: true
                onAccepted: successionsField.forceActiveFocus();
            }
        }

        FormGroupBox {
            id: plantingAmountBox
            width: parent.width
            title: qsTr("Amounts")

            ColumnLayout {
                width: parent.width
                spacing: 16

                RowLayout {
                    spacing: 16
                    MyTextField {
                        id: successionsField
                        text: "1"
                        inputMethodHints: Qt.ImhDigitsOnly
                        inputMask: "90"
                        floatingLabel: true
                        labelText: qsTr("Successions")
                        Layout.fillWidth: true
                        onAccepted: {
                            if (successions > 1)
                                timeBetweenSuccessionsField.forceActiveFocus();
                            else
                                plantingAmountField.forceActiveFocus();
                        }
                    }

                    MyTextField {
                        id: timeBetweenSuccessionsField
                        enabled: successions > 1
                        text: "1"
                        floatingLabel: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        inputMask: "90"
                        labelText: qsTr("Weeks between")
                        Layout.fillWidth: true

                        //                        suffixText: "weeks"
                    }
                }

                RowLayout {
                    spacing: 16
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
                        helperText: qsTr("Plants needed: ") + plantsNeeded()
                    }
                }
            }
        }

        FormGroupBox {
            width: parent.width
            title: qsTr("Planting Type")
            RowLayout {
                id: plantingTypeLayout
                Layout.fillWidth: true

                ButtonGroup {
                    buttons: plantingTypeLayout.children
                }

                ChoiceChip {
                    id: directSeedRadio
                    text: qsTr("Direct seed")
                    checked: true
                }

                ChoiceChip {
                    id: greenhouseRadio
                    text: qsTr("Transplant, raised")
                }
                ChoiceChip {
                    id: boughtRadio
                    text: qsTr("Transplant, bought")
                }
            }
        }
        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates") + (parseInt(successionsField)
                                             > 1 ? qsTr("(first succession)") : "")
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
                                                  parseInt(
                                                      text)).toLocaleString(
                                                  Qt.locale(), "ddd d MMM yyyy")
                    suffixText: qsTr("days")
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
                    inputMask: "900000"
                    labelText: qsTr("Needed")
                    Layout.fillWidth: true
                    text: seedsNeeded()
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
                    floatingLabel: true
                    labelText: qsTr("Per gram")
                    Layout.fillWidth: true
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
                    id: flatTypeField
                    floatingLabel: true
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "9000"
                    labelText: qsTr("Flat type")
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: seedsPerCellField
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    maximumLength: 10
                    text: "1"
                    floatingLabel: true
                    labelText: qsTr("Seeds per cell")
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: greenhouseEstimatedLossField
                    inputMethodHints: Qt.ImhDigitsOnly
                    inputMask: "90"
                    floatingLabel: true
                    labelText: qsTr("Estimated loss")
                    Layout.fillWidth: true
                    suffixText: qsTr("%")
                    helperText: transplantsNeeded()
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
                        //                        onDeleted: keywordsModel.remove(index)
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
}
