import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import io.croplan.components 1.0

Item {
    id: item3
    width: 400
    height: 600

    property alias varietyField: varietyField
    property alias cropField: cropField
    property int flatsNeeded

    ColumnLayout {
        id: columnLayout
        spacing: 8
        anchors.fill: parent

        GroupBox {
            id: groupBox
            Layout.fillWidth: true
            antialiasing: false
            title: qsTr("Planting")

            GridLayout {
                id: gridLayout
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                columns: 2

                Label {
                    id: label
                    text: qsTr("Crop:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    lineHeight: 1
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignTop
                    horizontalAlignment: Text.AlignRight
                }

                ComboBox {
                    id: cropField
                    Layout.fillWidth: true
                    editable: true
                    model: ["Lettuce", "Radish", "Tomato"]
                    focus: true

                }

                Label {
                    id: label1
                    text: qsTr("Variety:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                ComboBox {
                    id: varietyField
                    Layout.fillWidth: true
                    editable: true
                }

                Label {
                    id: label2
                    text: qsTr("Family:")
                    visible: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                ComboBox {
                    id: comboBox2
                    visible: false
                    Layout.fillWidth: true
                    editable: true
                }

                Label {
                    id: keywordsLabel
                    text: qsTr("Keywords:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                ComboBox {
                    id: keywordsField
                    Layout.fillWidth: true
                    editable: true
                }

                Label {
                    id: unitLabel
                    text: qsTr("Unit:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }

                ComboBox {
                    id: unitField
                    Layout.preferredWidth: 80
                    Layout.fillWidth: false
                    editable: true
                    model: ["kg", "bunch", "g"]
                }

                Label {
                    id: label3
                    text: qsTr("Successions:")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    MSpinBox {
                        id: successionsField
                        editable: true
                        value: 1
                        Layout.fillWidth: false
                    }

                    Label {
                        id: label4
                        text: qsTr("spaced by")
                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        enabled: successionsField.value > 1
                    }

                    MSpinBox {
                        id: timeBetweenField
                        editable: true
                        suffix: " " + qsTr("weeks")

                        Layout.fillWidth: false
                        enabled: successionsField.value > 1
                    }
                }

                Label {
                    id: plantingMethodLabel
                    text: qsTr("Planting method:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true

                    RadioButton {
                        id: directSeedRadio
                        text: "DS"
                        checked: true
                    }
                    RadioButton {
                        id: greenhouseRadio
                        text: "TP, greenhouse"
                    }
                    RadioButton {
                        id: boughtRadio
                        text: "TP, bougth"
                    }
                }
            }
        }

        GroupBox {
            id: groupBox1
            Layout.fillWidth: true
            title: qsTr("Quantity")

            GridLayout {
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                columns: 3

                Label {
                    id: label5
                    text: qsTr("Length")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                MSpinBox {
                    id: lengthField
                    editable: true
                    suffix: " " + qsTr("m")
                    Layout.fillWidth: false
                }

                Item {
                    Layout.fillWidth: true
                }

                Label {
                    id: label6
                    text: qsTr("In-row spacing")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                MSpinBox {
                    id: spinBox3
                    editable: true
                    Layout.fillWidth: false
                    suffix: " " + qsTr("cm")
                }

                Item {
                    Layout.fillWidth: true
                }

                Label {
                    id: label7
                    text: qsTr("Rows per bed")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                MSpinBox {
                    id: spinBox4
                    editable: true
                    Layout.fillWidth: false
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            id: plantingDatesBox
            Layout.fillWidth: true
            title: qsTr("Dates")

            GridLayout {
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                rows: 11
                columns: 4

                Label {
                    id: fieldSowingDateLabel
                    text: qsTr("Direct seed")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: directSeedRadio.checked
                }

                DatePicker {
                    id: datePicker
                    Layout.fillWidth: true
                    visible: fieldSowingDateLabel.visible
                }

                Label {
                    id: seedDtmLabel
                    text: qsTr("for")
                    visible: fieldSowingDateLabel.visible
                }

                MSpinBox {
                    id: spinBox
                    editable: true
                    suffix: " " + qsTr("days")

                    Layout.fillWidth: true

                    visible: fieldSowingDateLabel.visible
                }

                Label {
                    id: greenHouseStartDateLabel
                    text: qsTr("Start plant")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    visible: greenhouseRadio.checked
                }

                DatePicker {
                    id: greenhouseStartDateField
                    Layout.fillWidth: true
                    visible: greenHouseStartDateLabel.visible
                }

                Label {
                    id: greenhouseDttLabel
                    text: qsTr("for")
                    visible: greenHouseStartDateLabel.visible
                }

                MSpinBox {
                    id: greenhouseDttField
                    Layout.fillWidth: true
                    visible: greenHouseStartDateLabel.visible
                    suffix: " " + qsTr("days")
                }

                Label {
                    id: fieldPlantingDateLabel
                    text: qsTr("Plant")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: !directSeedRadio.checked
                }

                DatePicker {
                    id: fieldPlantingDateField
                    Layout.fillWidth: true
                    visible: fieldPlantingDateLabel.visible
                }

                Label {
                    id: greenhouseDtmLabel
                    text: qsTr("for")
                    visible: fieldPlantingDateLabel.visible
                }

                MSpinBox {
                    id: greenhouseDtmField
                    Layout.fillWidth: true
                    visible: fieldPlantingDateLabel.visible
                    suffix: " " + qsTr("days")
                }

                Label {
                    id: firstHarvestDateLabel
                    text: qsTr("Begin harvest")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }

                DatePicker {
                    id: firstHarvestDateField
                    Layout.fillWidth: true
                }

                Label {
                    id: harvestWindowLabel
                    text: qsTr("for")
                }

                MSpinBox {
                    id: harvestWindowField
                    editable: true
                    Layout.fillWidth: true
                    suffix: " " + qsTr("days")
                }
            }
        }

        GroupBox {
            id: greenhouseBox
            Layout.fillWidth: true
            title: qsTr("Greenhouse details")
            visible: greenhouseRadio.checked

            GridLayout {
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                rows: 11
                columns: 3

                Label {
                    id: flatSizeLabel
                    text: qsTr("Flat size")
                }

                Label {
                    id: seedsPerCellLabel
                    text: qsTr("Seeds per cell")
                }

                Label {
                    id: estimateLossLabel
                    text: qsTr("Estimated loss")
                }

                MSpinBox {
                    id: flatSizeField
                    Layout.fillWidth: true
                }

                MSpinBox {
                    id: seedsPerCellField
                    Layout.fillWidth: true
                }

                MSpinBox {
                    id: estimateLossField
                    Layout.fillWidth: true
                }

                Label {
                    id: label8
                    text: flatsNeeded + " " + qsTr("needed")
                    Layout.rowSpan: 3
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            id: seedsBox
            Layout.fillWidth: true
            title: qsTr("Seeds")
            visible: !boughtRadio.checked

            GridLayout {
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                columns: 3

                Label {
                    id: seedsNeeedLabel
                    text: qsTr("Seeds needed")
                }

                Label {
                    id: seedsExtraPercentageLabel
                    text: qsTr("Extra percentage")
                }

                Label {
                    id: seedsPerGramLabel
                    text: qsTr("Seeds/g")
                }

                MSpinBox {
                    id: seedsNeeedField
                    editable: true
                    Layout.fillWidth: true
                }

                MSpinBox {
                    id: seedsExtraPercentageField
                    editable: true
                    Layout.fillWidth: true
                }

                MSpinBox {
                    id: seedsPerGramField
                    editable: true
                    Layout.fillWidth: true
                }
            }
        }

        Item {
            id: item1
            width: 200
            height: 200
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
