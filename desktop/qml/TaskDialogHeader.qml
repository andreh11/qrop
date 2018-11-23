import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Rectangle {
    id: control

    readonly property int taskTypeId: taskTypeModel.rowId(typeField.currentIndex)
    readonly property alias completed: taskCompleteButton.checked
    property string completedDate: ""
    property int week
    property int year

    function reset() {
        typeField.currentIndex = 0
        taskCompleteButton.checked = false
    }

    implicitHeight: 60
    color: Material.color(Material.Grey, Material.Shade200)
    radius: 2
    clip: true
    Material.elevation: 2

   TaskTypeModel {
       id: taskTypeModel
       showPlantingTasks: false
   }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: Units.smallSpacing
        anchors {
            leftMargin: Units.mediumSpacing
            rightMargin: anchors.leftMargin
            topMargin: Units.smallSpacing
            bottomMargin: anchors.topMargin
        }
        
        Rectangle {
            id: textIcon
            Layout.alignment: Qt.AlignVCenter
            height: 40
            width: height
            radius: 80
            border.width: 4
            border.color: Material.color(Material.Green, Material.Shade400)
            
            Text {
                anchors.centerIn: parent
                text: {
                    var stringList =  typeField.currentText.split(" ");
                    if (stringList.length > 1)
                        return stringList[0][0] + stringList[1][0].toString().toUpperCase()
                    else
                        return stringList[0][0]
                }
                color: "black"
                font { family: "Roboto Regular"; pixelSize: 20 }
            }
        }
        
        MyComboBox {
            id: typeField
            labelText: qsTr("Type")
            floatingLabel: true
            editable: false
            Layout.fillWidth: true
            model: taskTypeModel
            showAddItem: true

            addItemText: qsTr("Add Type")

            textRole: "type"
            onAccepted: if (find(editText) === -1)
                            model.append({text: editText})
        }
        
        TaskCompleteButton {
            id: taskCompleteButton
            onCheckedChanged: {
                if (checked)
                    control.completedDate = new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
                else
                    control.completedDate = ""
            }
        }
        
        //        ColumnLayout {
        //            Label {
        //                text: qsTr("Revenue")
        //                font { family: "Roboto Regular"; pixelSize: Units.fontSizeCaption }
        //                color: Qt.rgba(0,0,0, 0.50)
        //                Layout.alignment: Qt.AlignRight
        //            }
        //            Label {
        //                id: estimatedRevenueLabel
        //                text: "%L1 €".arg(estimatedRevenue)
        //                horizontalAlignment: Text.AlignHCenter
        //                font { family: "Roboto Regular"; pixelSize: Units.fontSizeBodyAndButton }
        //                color: Qt.rgba(0,0,0, 0.87)
        //                Layout.alignment: Qt.AlignRight
        //            }
        //        }
    }
}
