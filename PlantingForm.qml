import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Flickable {
    property alias plantingMethod: plantingMethodCombo.currentIndex

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

        switch(plantingMethod) {
            case 0: // DS
                seeds = plantsNeeded() * (1 + extraPercentage/100);
                break;
            case 1: // Transplant, greenhouse
                seeds = transplantsNeeded() * (1 + extraPercentage/100);
                break;
            default: // Transplant, bought
                seeds = plantsNeeded();
                break;
        }

        return seeds
    }

    function transplantsNeeded() {
        var flatType = parseInt(flatTypeField.text)
        var seedsPerCell = parseInt(seedsPerCellField.text)
        var estimatedLoss = parseInt(greenhouseEstimatedLossField.text)

        return plantsNeeded() * seedsPerCell / flatType
    }


    Column {
        anchors.fill: parent
        spacing: 16
        
        ColumnLayout {
            width: parent.width
            spacing: 16
            
            MyTextField {
                floatingLabel: true
                placeholderText: qsTr("Crop")
                Layout.fillWidth: true
            }
            
            MyTextField {
                floatingLabel: true
                placeholderText: qsTr("Variety")
                Layout.fillWidth: true
            }
            
            MyTextField {
                floatingLabel: true
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
                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Number of successions")
                    Layout.fillWidth: true
                }
                
                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Time between successions")
                    Layout.fillWidth: true
                    suffixText: "days"
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
                MyTextField {
                    id: plantingAmountField
                    floatingLabel: true
                    placeholderText: qsTr("Planting Amount")
                    Layout.fillWidth: true
                    suffixText: "bed m"
                }
                
                MyTextField {
                    id: inRowSpacingField
                    floatingLabel: true
                    placeholderText: qsTr("In-row spacing")
                    Layout.fillWidth: true
                    suffixText: "cm"
                }
                
                MyTextField {
                    id: rowsPerBedField
                    floatingLabel: true
                    placeholderText: qsTr("Rows per bed")
                    Layout.fillWidth: true
                    helperText: qsTr("Plants needed: ") + plantsNeeded()
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
                    Material.elevation: 0
                    Layout.fillWidth: true
                    width: parent.width
                    padding: 0
                    model : [qsTr("Direct sow"), qsTr("Transplant, greenhouse"), qsTr("Transplant, purchased")]
                    
                    background : Item {
                        id: background
                        //                        implicitWidth: Math.max(250, control.width)
                        Rectangle {
                            id: underline
                            color: "transparent"
                            radius: 4
                            border.color: (control.activeFocus ? Material.color(Material.accent)
                                                                             : Material.color(Material.Grey))

                            border.width: control.activeFocus ? 2 : 1
                            height: parent.height
                            visible: true
//                            visible: background.showBorder
                            width: parent.width
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4

                            Behavior on height {
                                NumberAnimation { duration: 200 }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex == 0
                    MyTextField {
                        id: fieldSowingDate
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Field Sowing Date")
                    }
                    
                    MyTextField {
                        id: sowDtm
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Days to maturity")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex == 1
                    MyTextField {
                        id: greenhouseStartDate
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Greenhouse start date")
                    }
                    
                    MyTextField {
                        id: greenhouseGrowTime
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Greenhouse duration")
                        suffixText: qsTr("days")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    visible: plantingMethodCombo.currentIndex > 0
                    MyTextField {
                        id: fieldPlantingDate
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Field planting date")
                    }
                    
                    MyTextField {
                        id: plantingDtm
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Days to maturity")
                        suffixText: qsTr("days")
                    }
                }
                
                RowLayout {
                    width: parent.width
                    anchors.topMargin: 16
                    spacing: 16
                    MyTextField {
                        id: firstHarvestDate
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("First harvest date")
                    }
                    
                    MyTextField {
                        id: harvestWindow
                        Layout.fillWidth: true
                        floatingLabel: true
                        placeholderText: qsTr("Harvest window")
                        helperText: text === "" ? "" : "Last harvest: 12/4"
                        suffixText: qsTr("days")
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
            visible: plantingMethodCombo.currentIndex == 1
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
