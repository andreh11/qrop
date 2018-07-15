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

        GroupBox {
            id: successionsBox
//            title: qsTr("Greenhouse details")
            width: parent.width
            padding: 8
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
                }
            }
        }

        GroupBox {
            id: plantingAmountBox
//            title: qsTr("Greenhouse details")
            width: parent.width
            padding: 8
            RowLayout {
                anchors.fill: parent
                anchors.topMargin: 16
                spacing: 16
                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Planting Amount")
                    Layout.fillWidth: true
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("In-row spacing")
                    Layout.fillWidth: true
                }

                MyTextField {
                    floatingLabel: true
                    placeholderText: qsTr("Rows per bed")
                    Layout.fillWidth: true
                }


            }
        }


        GroupBox {
            id: plantingDatesBox
            title: qsTr("Planting dates")
            width: parent.width
            spacing: 16

            ColumnLayout {
                anchors.fill: parent

                ComboBox {
                    id: plantingMethodCombo
                    Layout.fillWidth: true
                    width: parent.width
                    model : [qsTr("Direct sow"), qsTr("Transplant, greenhouse"), qsTr("Transplant, purchased")]
                }

                ThinDivider {
                    width: parent.width
                    Layout.fillWidth: true
                }

            RowLayout {
                width: parent.width
                anchors.topMargin: 16
                spacing: 16
                MyTextField {
                    id: fieldSowingDate
                    visible: plantingMethodCombo.currentIndex == 0
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Field Sowing Date")
                }

                MyTextField {
                    id: ghStartDate
                    visible: plantingMethodCombo.currentIndex == 1
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("GH starting date")
                }

                MyTextField {
                    id: fieldPlantingDate
                    visible: plantingMethodCombo.currentIndex > 0
                    Layout.fillWidth: true
                    floatingLabel: true
                    placeholderText: qsTr("Field Planting Date")
                }

                MyTextField {
                    id: firstHarvestDate
                    floatingLabel: true
                    placeholderText: qsTr("First Harvest")
                    Layout.fillWidth: true
                }

                MyTextField {
                    id: harvestWindow
                    floatingLabel: true
                    Layout.fillWidth: true
                    placeholderText: qsTr("Harvest Window")
                    helperText: text
                }
            }

            }
        }

        GroupBox {
            id: greenhouseBox
            title: qsTr("Greenhouse details")
            width: parent.width
            padding: 8
            RowLayout {
                width: parent.width
                spacing: 0
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
                }
            }
        }
    }
    }

}
