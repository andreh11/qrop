import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Dialog {
    id: dialog
    modal: true
    title: "Add planting(s)"
    standardButtons: Dialog.Ok | Dialog.Cancel

    Flickable {
        anchors.fill: parent
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
//            title: qsTr("Greenhouse details")
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
//            title: qsTr("Greenhouse details")
            width: parent.width
            RowLayout {
                anchors.fill: parent
                anchors.topMargin: 16
                spacing: 16
                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Planting Amount")
                    Layout.fillWidth: true
                    suffixText: "bed m"
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("In-row spacing")
                    Layout.fillWidth: true
                    suffixText: "cm"
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Rows per bed")
                    Layout.fillWidth: true
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
            color:  (plantingMethodCombo.activeFocus ? Material.color(Material.accent)
                                                             : Material.color(Material.Grey))

            height: plantingMethodCombo.activeFocus ? 2 : 1
            visible: true

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: -4
            }

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
                    floatingLabel: true
                    placeholderText: qsTr("Seeds needed")
                    Layout.fillWidth: true
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Extra %")
                    suffixText: "%"
                    Layout.fillWidth: true
                }

                MyTextField {
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
                    floatingLabel: true
                    placeholderText: qsTr("Flat type")
                    Layout.fillWidth: true
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Seeds per cell")
                    Layout.fillWidth: true
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Estimated loss")
                    Layout.fillWidth: true
                    suffixText: qsTr("%")
                }
            }
        }

        }
    }
    }

