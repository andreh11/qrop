import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

Item {
    id: item3
    width: 600
    height: 600
    property alias varietyField: varietyField
    property alias cropField: cropField
    property int flatsNeeded

    ColumnLayout {
        id: columnLayout
        anchors.rightMargin: 8
        anchors.leftMargin: 8
        anchors.bottomMargin: 8
        anchors.topMargin: 8
        spacing: 8
        anchors.fill: parent

        GroupBox {
            id: groupBox
            checkable: false
            Layout.fillWidth: true
            antialiasing: false
            title: qsTr("Planting")
            flat: false
            checked: false

            GridLayout {
                id: gridLayout
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                rows: 13
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
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                ComboBox {
                    id: comboBox2
                    Layout.fillWidth: true
                    editable: true
                }

                Label {
                    id: plantingMethodLabel
                    text: qsTr("Planting method:")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    ExclusiveGroup {
                        id: tabPositionGroup
                    }
                    RadioButton {
                        text: "DS"
                        checked: true
                        exclusiveGroup: tabPositionGroup
                    }
                    RadioButton {
                        text: "TP, bougth"
                        exclusiveGroup: tabPositionGroup
                    }
                    RadioButton {
                        text: "TP, greenhouse"
                        exclusiveGroup: tabPositionGroup
                    }
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
                    id: label3
                    text: qsTr("Successions:")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    SpinBox {
                        id: successionsField
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

                    SpinBox {
                        id: timeBetweenField
                        maximumValue: 52
                        minimumValue: 1
                        suffix: " weeks"
                        Layout.fillWidth: false
                        enabled: successionsField.value > 1
                    }
                }

                ComboBox {
                    id: plantinMethodField
                    Layout.fillWidth: true
                    visible: false
                    model: ["Direct sow", "Transplant, greenhouse", "Transplant, bought"]
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
                rows: 11
                columns: 3
                Label {
                    id: label5
                    text: qsTr("Length")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                SpinBox {
                    id: lengthField
                    suffix: " m"
                    minimumValue: 1
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

                SpinBox {
                    id: spinBox3
                    suffix: " cm"
                    Layout.fillWidth: false
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

                SpinBox {
                    id: spinBox4
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
                    visible: plantinMethodField.currentIndex == 0
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

                SpinBox {
                    id: spinBox
                    minimumValue: 1
                    Layout.fillWidth: true
                    suffix: " " + qsTr("days")
                    visible: fieldSowingDateLabel.visible
                }

                Label {
                    id: greenHouseStartDateLabel
                    text: qsTr("Start plant")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    visible: plantinMethodField.currentIndex == 1
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

                SpinBox {
                    id: greenhouseDttField
                    minimumValue: 1
                    Layout.fillWidth: true
                    suffix: " " + qsTr("days")
                    visible: greenHouseStartDateLabel.visible
                }

                Label {
                    id: fieldPlantingDateLabel
                    text: qsTr("Plant")
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: plantinMethodField.currentIndex >= 1
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

                SpinBox {
                    id: greenhouseDtmField
                    minimumValue: 1
                    Layout.fillWidth: true
                    suffix: " " + qsTr("days")
                    visible: fieldPlantingDateLabel.visible
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

                SpinBox {
                    id: harvestWindowField
                    minimumValue: 1
                    Layout.fillWidth: true
                    suffix: " " + qsTr("days")
                }
            }
        }

        GroupBox {
            id: greenhouseBox
            Layout.fillWidth: true
            title: qsTr("Greenhouse details")
            visible: plantinMethodField.currentIndex == 1

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

                SpinBox {
                    id: flatSizeField
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: seedsPerCellField
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: estimateLossField
                    Layout.fillWidth: true
                    suffix: " " + qsTr("%")
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
            visible: plantinMethodField.currentIndex < 2

            GridLayout {
                anchors.fill: parent
                columnSpacing: 8
                rowSpacing: 8
                rows: 11
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

                SpinBox {
                    id: seedsNeeedField
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: seedsExtraPercentageField
                    Layout.fillWidth: true
                    suffix: " " + qsTr("%")
                }

                SpinBox {
                    id: seedsPerGramField
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
