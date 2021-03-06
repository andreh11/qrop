import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Column {
    id: control

    property int firstColumnWidth
    property int secondColumnWidth

    signal refresh()

    Rectangle {
        color: "white"
        width: parent.width
        height: Units.listSingleLineHeight

        MouseArea {
            id: taskTypeMouseArea
            height: parent.height
            width: parent.width
            hoverEnabled: true

            RowLayout {
                id: headerRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: parent.height
                spacing: Units.mediumSpacing

                TextDisk {
                    id: colorDisk
//                    text: type.slice(0,2)
                    text: {

                        var stringList = type.split(" ");
                        if (stringList.length > 1)
                            return stringList[0][0] + stringList[1][0].toString().toUpperCase()
                        else
                            return stringList[0][0] + stringList[0][1]
                    }
                    color: model.color
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    onClicked: colorPickerDialog.open()

                    Dialog {
                        id: colorPickerDialog
                        width: 400
                        height: 400
                        margins: 0
                        ColorPicker {
                            anchors.fill: parent
                            onNewColorSelected: {
                                colorPickerDialog.close()
                                TaskType.update(model.task_type_id, {"color": color});
                                refresh();
                            }
                        }
                    }
                }

                EditableLabel {
                    text: type
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.fillHeight: true
                    onEditingFinished: {
                        TaskType.update(task_type_id, {"type": text})
                        refresh();
                    }
                }

                Item { Layout.fillWidth: true }

                MyToolButton {
                    visible: taskTypeMouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove task type")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    onClicked: deleteDialog.open()

                    Dialog {
                        id: deleteDialog
                        title: qsTr("Delete %1?").arg(type)
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All related tasks will be lost.")
                        }

                        onAccepted: {
                            TaskType.remove(task_type_id)
                            refresh();
                        }

                        onRejected: deleteDialog.close()
                    }
                }

                MyToolButton {
                    id: showCropsButton
                    Layout.leftMargin: -28
                    Layout.rightMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    checkable: true
                    text: "\ue313"
                    rotation: checked ? 180 : 0
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: checked ? qsTr("Hide methods") : qsTr("Show methods")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                }
            }
        }
    }

    ListView {
        id: view
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        spacing: 0
        visible: showCropsButton.checked
        width: parent.width
        height: contentHeight

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: scrollBar }

        model: TaskMethodModel {
            id: taskImplementModel
            typeId: task_type_id
        }

        delegate: SettingsTaskMethodDelegate {
            width: parent.width
            listPadding: colorDisk.width + headerRow.spacing
            onRefresh: taskImplementModel.refresh()
            firstColumnWidth: control.firstColumnWidth
            secondColumnWidth: control.secondColumnWidth
        }
    }

    FlatButton {
        id: addMethodButton
        visible: showCropsButton.checked
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        text: qsTr("Add method")
        Material.foreground: Material.accent
        onClicked: addDialog.open();
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.rightMargin: Units.formSpacing

        SimpleAddDialog {
            id: addDialog
            title: qsTr("Add method")

            onAccepted: {
                TaskMethod.add({"method" : text,
                                   "task_type_id" : model.task_type_id});

                taskImplementModel.refresh();
            }
        }
    }

    ThinDivider { width: parent.width }
}
