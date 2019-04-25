import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Rectangle {
    id: control

    property int taskId: -1
    readonly property int taskTypeId: typeField.selectedId
    property string completedDate: ""
    readonly property bool completed: completedDate
    property alias typeField: typeField
    property int week
    property int year
    property bool sowPlantTask: false
    property bool templateMode: false

    function reset() {
        completedDate = "";
        taskTypeModel.refresh();
        typeField.selectedId = -1;
        typeField.text = "";
    }

    focus: true
    implicitHeight: 60
    color: Material.color(Material.Grey, Material.Shade200)
    radius: 2
    clip: true
    Material.elevation: 2

    TaskTypeModel {
        id: taskTypeModel
        showPlantingTasks: sowPlantTask
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
            border.width: 2
            border.color: Material.color(Material.Green, Material.Shade400)

            Text {
                anchors.centerIn: parent
                text: {
                    if (taskTypeId <= 0)
                        return "";

                    var stringList =  typeField.text.split(" ");
                    if (stringList.length > 1)
                        return stringList[0][0] + stringList[1][0].toString().toUpperCase()
                    else
                        return stringList[0][0] + stringList[0][1]
                }
                color: "black"
                font { family: "Roboto Regular"; pixelSize: 20 }
            }
        }

        ComboTextField {
            id: typeField
            labelText: qsTr("Type")
            floatingLabel: true
            model: taskTypeModel
            showAddItem: true
            addItemText: text ? qsTr('Add new type "%1"').arg(text) : qsTr("Add new type")
            enabled: templateMode || !sowPlantTask
            Layout.topMargin: Units.smallSpacing
            textRole: function (model) { return model.type; }
            idRole: function (model) { return model.task_type_id; }
            Layout.fillWidth: true

            onAddItemClicked: {
                addTypeDialog.open();
                addTypeDialog.prefill(text);
            }

            SimpleAddDialog {
                id: addTypeDialog
                validator: RegExpValidator { regExp: /\w[\w\d- ]*/ }
                title: qsTr("Add Type")
                onAccepted:  {
                    var id = TaskType.add({"type" : text});
                    taskTypeModel.refresh();
                    typeField.selectedId = id;
                    typeField.text = text;
                }
            }
        }

        TaskCompleteButton {
            id: taskCompleteButton
            done: control.completedDate

            ToolTip.text: control.completedDate
                          ? qsTr("Done on %1. Click to undo.").arg(Date.fromLocaleDateString(Qt.locale(), control.completedDate, "yyyy-MM-dd").toLocaleDateString(Qt.locale(), Locale.ShortFormat))
                          : qsTr("Click to complete task. Hold to select date.")
            ToolTip.visible: hovered

            onClicked: {
                if (checked)
                    control.completedDate = new Date().toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
                else
                    control.completedDate = ""
            }

            onPressAndHold: calendarPopup.open();

            Popup {
                id: calendarPopup

                width: contentItem.width
                height: contentItem.height
                y: parent.width - calendarView.height
                x: parent.height - calendarView.width
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                padding: 0
                margins: 0

                contentItem: CalendarView {
                    id: calendarView

                    clip: true
                    year: page.year
                    month: (new Date()).getMonth()

                    onDateSelect: {
                        completedDate = newDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
                        calendarPopup.close();
                    }
                }
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
