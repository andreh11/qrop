import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Flickable {
    focus: true
    property alias plantingMethod: plantingMethodCombo.currentIndex
    property alias crop: cropField.text

    function plantsNeeded() {
        if (plantingAmountField.empty
                || inRowSpacingField.empty
                || rowsPerBedField.empty) {
            return 0;
        }

        var plantingAmount = parseInt(plantingAmountField.text);
        var inRowSpacing = parseInt(inRowSpacingField.text);
        var rowsPerBed = parseInt(rowsPerBedField.text);

        return plantingAmount / inRowSpacing * 100 * rowsPerBed;
    }

    function seedsNeeded() {
        var extraPercentage = 0;
        var seeds = 0;
        var seedsPerCell = 1;

        if (seedsExtraPercentageField.empty)
            extraPercentage = parseInt(seedsExtraPercentageField.text);

        if (extraPercentage === Number.NaN)
            extraPercentage = 0;

        if (!seedsPerCellField.empty)
            seedsPerCell = parseInt(seedsPerCellField.text);

        switch (plantingMethod) {
        case 0: // DS
            seeds = plantsNeeded() * (1 + extraPercentage/100);
            break;
        case 1: // Transplant, greenhouse
            seeds = transplantsNeeded() * seedsPerCell * (1 + extraPercentage/100);
            break;
        default: // Transplant, bought
            seeds = 0;
            break;
        }

        return Math.round(seeds)
    }

    function transplantsNeeded() {
        var estimatedLoss =  0

        if (!greenhouseEstimatedLossField.empty)
            estimatedLoss = parseInt(greenhouseEstimatedLossField.text);

        return plantsNeeded() / (1 - (estimatedLoss/100));
    }

    function flatsNeeded() {
        if (flatTypeField.empty)
            return 0;

        var flatSize = parseInt(flatTypeField.text)
        console.log("flat size:", flatSize);
        return (transplantsNeeded() / flatSize).toFixed(2);
    }

    Component.onCompleted: cropField.focus = true

    Column {
        anchors.fill: parent
        spacing: 16
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            TextField {
                id: cropField
                ////floatingLabel: true
                placeholderText: qsTr("Crop")
                Layout.fillWidth: true
            }

            ComboBox {
                Layout.fillWidth: true
                model: CropModel { }
                textRole: "name"
                editable: true
                focus: true
            }

            TextField {
                id: varietyField
                //floatingLabel: true
                placeholderText: qsTr("Variety")
                Layout.fillWidth: true
            }
            
            TextField {
                id: familyField
                //floatingLabel: true
                placeholderText: qsTr("Family")
                Layout.fillWidth: true
            }
        }
        
        FormGroupBox {
            id: successionsBox
            width: parent.width
            RowLayout {
                anchors.fill: parent
                anchors.topMargin: 16
                spacing: 16
                TextField {
                    //floatingLabel: true
                    placeholderText: qsTr("Number of successions")
                    Layout.fillWidth: true
                }
                
                TextField {
                    //floatingLabel: true
                    placeholderText: qsTr("Time between")
                    Layout.fillWidth: true
                    //suffixText: "weeks"
                }
            }
        }
        
        FormGroupBox {
            id: plantingAmountBox
            width: parent.width
            RowLayout {
                anchors.fill: parent
                anchors.topMargin: 16
                spacing: 16
                TextField {
                    id: plantingAmountField
                    //floatingLabel: true
                    placeholderText: qsTr("Length")
                    Layout.fillWidth: true
                    //suffixText: "bed m"
                }
                
                TextField {
                    id: inRowSpacingField
                    //floatingLabel: true
                    placeholderText: qsTr("In-row spacing")
                    Layout.fillWidth: true
                    //suffixText: "cm"
                }
                
                TextField {
                    id: rowsPerBedField
                    //floatingLabel: true
                    placeholderText: qsTr("Rows per bed")
                    Layout.fillWidth: true
                    //helperText: qsTr("Plants needed: ") + plantsNeeded()
                }
            }
        }
        
        FormGroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates")
            width: parent.width
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                ComboBox {
                    id: plantingMethodCombo
                    Layout.fillWidth: true
                    model : [qsTr("Direct sow"),
                        qsTr("Transplant, greenhouse"),
                        qsTr("Transplant, purchased")]
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex == 0
                    TextField {
                        id: fieldSowingDate
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Field Sowing Date")
                    }
                    
                    TextField {
                        id: sowDtm
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Days to maturity")
                        //suffixText: qsTr("days")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex == 1
                    TextField {
                        id: greenhouseStartDate
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Greenhouse start date")
                    }
                    
                    TextField {
                        id: greenhouseGrowTime
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Days to transplant")
                        //suffixText: qsTr("days")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex > 0
                    TextField {
                        id: fieldPlantingDate
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Field planting date")
                    }
                    
                    TextField {
                        id: plantingDtm
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Days to maturity")
                        //suffixText: qsTr("days")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    TextField {
                        id: firstHarvestDate
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("First harvest date")
                    }
                    
                    TextField {
                        id: harvestWindow
                        Layout.fillWidth: true
                        //floatingLabel: true
                        placeholderText: qsTr("Harvest window")
                        //suffixText: qsTr("days")
                        //helperText: text === "" ? "" : "Last harvest: 12/4"
                    }
                }
            }
        }
        
        FormGroupBox {
            id: seedBox
            title: qsTr("Seeds")
            visible: plantingMethodCombo.currentIndex < 2
            RowLayout {
                width: parent.width
                spacing: 16
                TextField {
                    id: seedsNeededField
                    //floatingLabel: true
                    placeholderText: qsTr("Seeds needed")
                    Layout.fillWidth: true
                    text: seedsNeeded()
                }
                
                TextField {
                    id: seedsExtraPercentageField
                    //floatingLabel: true
                    placeholderText: qsTr("Extra %")
                    //suffixText: "%"
                    Layout.fillWidth: true
                }
                
                TextField {
                    id: seedsPerGramField
                    //floatingLabel: true
                    placeholderText: qsTr("Seeds/g")
                    Layout.fillWidth: true
                }
            }
        }

        FormGroupBox {
            id: greenhouseBox
            title: qsTr("Greenhouse details")
            visible: plantingMethodCombo.currentIndex == 1
            RowLayout {
                width: parent.width
                spacing: 16
                TextField {
                    id: flatTypeField
                    //floatingLabel: true
                    placeholderText: qsTr("Flat type")
                    Layout.fillWidth: true
                }
                
                TextField {
                    id: seedsPerCellField
                    //floatingLabel: true
                    placeholderText: qsTr("Seeds per cell")
                    Layout.fillWidth: true
                }
                
                TextField {
                    id: greenhouseEstimatedLossField
                    //floatingLabel: true
                    placeholderText: qsTr("Estimated loss")
                    Layout.fillWidth: true
                    //suffixText: qsTr("%")
                    //helperText: "Flats needed: " + flatsNeeded()
                }
            }
        }
    }
}
