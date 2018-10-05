import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Flickable {
    id: control

    property bool directSeeded: directSeedRadio.checked
    property bool transplantRaised: greenhouseRadio.checked
    property bool transplantBought: boughtRadio.checked

    property int plantingType : directSeedRadio.checked ? 1 : (greenhouseRadio.checked ? 2 : 3)

    property variant values:  {
        "variety_id" : varietyField.currentIndex + 1,
        "unit_id" : unitCombo.currentIndex + 1,
        "planting_type" : plantingType,
        "length" : parseInt(plantingAmountField.text),
        "spacing_plants" : parseInt(inRowSpacingField.text),
        "rows" : parseInt(rowsPerBedField.text),
        "planting_date" : plantingType === 1 ? fieldPlantingDate.isoDateString
                                             : fieldPlantingDate.isoDateString,
        "dtm" : parseInt(plantingType === 1 ? sowDtm.text : plantingDtm.text),
        "dtt" : plantingType === 2 ? parseInt(greenhouseGrowTime.text) : 0
    }

    property int successions: parseInt(successionsField.text)
    property int weeksBetween: parseInt(timeBetweenSuccessionsField.text)

    function updateDateField(from, length, to, direction) {
        if (length.text === "")
            to.calendarDate = from.calendarDate;
        else
            to.calendarDate = addDays(from.calendarDate, parseInt(length.text) * direction);
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
        if (extraPercentage === Number.NaN) {
            extraPercentage = 0
        }

        if (directSeedRadio.checked)
            seeds = plantsNeeded() * (1 + extraPercentage/100);
        else if (greenhouseRadio.checked)
            seeds = transplantsNeeded() * (1 + extraPercentage/100);
        else
            seeds = plantsNeeded();

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
    focus: true
    flickableDirection: Flickable.VerticalFlick

    Column {
        id: mainColumn
        width: parent.width
        spacing: 8

        ColumnLayout {
            width: parent.width
            spacing: 8

            MyComboBox {
                id: cropField
//                floatingLabel: true
//                placeholderText: qsTr("Crop")
                Layout.fillWidth: true
                Layout.topMargin: largeDisplay ? 8 : 0 // avoid clipping of floatingLabel
                focus: true
                model: CropModel { id: cropModel }
                textRole: "crop"
                editable: true
                onCurrentIndexChanged: varietyModel.cropId = currentIndex
            }

            MyComboBox {
                id: varietyField
//                floatingLabel: true
//                placeholderText: qsTr("Variety")
                Layout.fillWidth: true
                editable: true
                model: VarietyModel {
                    id: varietyModel
                }
                textRole: "variety"
            }

            MyTextField {
                id: keywordsField
                floatingLabel: true
                placeholderText: qsTr("Keywords")
                Layout.fillWidth: true
            }

            MyComboBox {
                id: unitCombo
                model : UnitModel { }
                textRole: "unit"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: -16

                RadioButton {
                    id: directSeedRadio
                    text: qsTr("Direct seed")
                    checked: true
                    Layout.fillWidth: true
                }
                RadioButton {
                    id: greenhouseRadio
                    text: qsTr("Transplant, raised")
                    Layout.fillWidth: true
                }
                RadioButton {
                    id: boughtRadio
                    text: qsTr("Transplant, bought")
                    Layout.fillWidth: true
                }
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
                        inputMethodHints: Qt.ImhDigitsOnly
                        floatingLabel: true
                        placeholderText: qsTr("Successions")
                        Layout.fillWidth: true
                    }

                    MyTextField {
                        id: timeBetweenSuccessionsField
                        floatingLabel: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        placeholderText: qsTr("Weeks between")
                        Layout.fillWidth: true
//                        suffixText: "weeks"
                    }
                }

                RowLayout {
                    spacing: 16
                    MyTextField {
                        id: plantingAmountField
                        floatingLabel: true
                        placeholderText: qsTr("Length")
                        Layout.fillWidth: true
                        suffixText: "bed m"
                    }

                    MyTextField {
                        id: inRowSpacingField
                        floatingLabel: true
                        placeholderText: qsTr("Spacing")
                        Layout.fillWidth: true
                        suffixText: "cm"
                    }

                    MyTextField {
                        id: rowsPerBedField
                        floatingLabel: true
                        placeholderText: qsTr("Rows")
                        Layout.fillWidth: true
                        helperText: qsTr("Plants needed: ") + plantsNeeded()
                    }
                }


            }
        }

        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates") + (parseInt(successionsField) > 1 ? qsTr("(first succession)") : "")
            width: parent.width

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: 16
                columnSpacing: 16

                DatePicker {
                    id: fieldSowingDate
                    visible: directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Field Sowing Date")

                    onEditingFinished: updateDateField(fieldSowingDate, sowDtm, firstHarvestDate, 1)
                }

                MyTextField {
                    id: sowDtm
                    visible: fieldSowingDate.visible
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: "1"
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Days to maturity")

                    onTextChanged: updateDateField(fieldSowingDate, sowDtm, firstHarvestDate, 1)
                }

                DatePicker {
                    id: greenhouseStartDate
                    visible: greenhouseRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Greenhouse start date")

                    onEditingFinished: updateDateField(greenhouseStartDate, greenhouseGrowTime, fieldPlantingDate, 1)
                }

                MyTextField {
                    id: greenhouseGrowTime
                    visible: greenhouseStartDate.visible
                    text: "1"
                    inputMethodHints: Qt.ImhDigitsOnly
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Greenhouse duration")
                    suffixText: qsTr("days")

                    onTextChanged:  updateDateField(greenhouseStartDate, greenhouseGrowTime, fieldPlantingDate, 1)
                }

                DatePicker {
                    id: fieldPlantingDate
                    visible: !directSeedRadio.checked
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Field planting date")

                    onEditingFinished: updateDateField(fieldPlantingDate, greenhouseGrowTime, greenhouseStartDate, -1);
                    onCalendarDateChanged: updateDateField(fieldPlantingDate, plantingDtm, firstHarvestDate, 1);
                }

                MyTextField {
                    id: plantingDtm
                    visible: fieldPlantingDate.visible
                    text: "1"
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Days to maturity")
                    suffixText: qsTr("days")

                    onTextChanged: updateDateField(fieldPlantingDate, plantingDtm, firstHarvestDate, 1);
                }

                DatePicker {
                    id: firstHarvestDate
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("First harvest date")

                    onEditingFinished: {
                        if (directSeeded)
                            updateDateField(firstHarvestDate, sowDtm, fieldSowingDate, -1);
                        else
                            updateDateField(firstHarvestDate, plantingDtm, fieldPlantingDate, -1);
                    }
                }

                MyTextField {
                    id: harvestWindow
                    text: "1"
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Harvest window")
                    helperText: text === "" ? "" : qsTr("Last: ") + addDays(firstHarvestDate.calendarDate, parseInt(text)).toLocaleString(Qt.locale(), "ddd d MMM yyyy")
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
                    placeholderText: qsTr("Seeds needed")
                    Layout.fillWidth: true
                    text: seedsNeeded()
                }

                MyTextField {
                    id: seedsExtraPercentageField
                    floatingLabel: true
                    placeholderText: qsTr("Extra %")
                    suffixText: "%"
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: seedsPerGramField
                    floatingLabel: true
                    placeholderText: qsTr("Seeds/g")
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
                    placeholderText: qsTr("Flat type")
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: seedsPerCellField
                    inputMethodHints: Qt.ImhDigitsOnly
                    maximumLength: 10
                    text: "1"
                    floatingLabel: true
                    placeholderText: qsTr("Seeds per cell")
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: greenhouseEstimatedLossField
                    floatingLabel: true
                    placeholderText: qsTr("Estimated loss")
                    Layout.fillWidth: true
                    suffixText: qsTr("%")
                    helperText: transplantsNeeded()
                }
            }
        }
    }
}
