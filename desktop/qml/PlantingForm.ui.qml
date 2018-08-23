import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    id: item3
    width: 600
    height: 400
    property alias varietyField: varietyField
    property alias cropField: cropField
    property alias label1: label1

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
            width: 360
            height: 193
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
                rows: 11
                columns: 3

                Label {
                    id: label
                    text: qsTr("Crop")
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    id: label1
                    text: qsTr("Variety")
                }

                Label {
                    id: label2
                    text: qsTr("Family")
                }

                ComboBox {
                    id: cropField
                    Layout.fillWidth: true
                    editable: true
                    focus: true
                }

                ComboBox {
                    id: varietyField
                    Layout.fillWidth: true
                    editable: true
                }

                ComboBox {
                    id: comboBox2
                    Layout.fillWidth: true
                    editable: true
                }

                Label {
                    id: label3
                    text: qsTr("Successions")
                    Layout.fillWidth: true
                }

                Label {
                    id: label4
                    text: qsTr("Time between")
                    Layout.fillWidth: true
                    enabled: successionsField.value > 1
                }

                Item {
                    width: 1
                    height: 1
                }

                SpinBox {
                    id: successionsField
                    value: 1
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: timeBetweenField
                    maximumValue: 52
                    minimumValue: 1
                    suffix: " weeks"
                    Layout.fillWidth: true
                    enabled: successionsField.value > 1
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            id: groupBox1
            width: 360
            height: 300
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
                }

                Label {
                    id: label6
                    text: qsTr("In-row spacing")
                }

                Label {
                    id: label7
                    text: qsTr("Rows per bed")
                }

                SpinBox {
                    id: spinBox2
                    minimumValue: 1
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: spinBox3
                    Layout.fillWidth: true
                }

                SpinBox {
                    id: spinBox4
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
