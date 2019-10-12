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
    property int listPadding

    signal refresh()

    Rectangle {
        id: delegate
        height: childrenRect.height
        width: parent.width

        MouseArea {
            id: mouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true

            RowLayout {
                id: row
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Units.rowHeight
                spacing: Units.formSpacing

                EditableLabel {
                    text: model.method
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.fillHeight: true
                    Layout.leftMargin: Units.mediumSpacing + listPadding
                    onEditingFinished: {
                        TaskMethod.update(model.task_method_id, {"method": text});
                        refresh();
                    }
                }

                Item { height: 1; Layout.fillWidth: true }

                MyToolButton {
                    visible: mouseArea.containsMouse
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove method")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200

                    onClicked: deleteDialog.open()

                    Dialog {
                        id: deleteDialog
                        title: qsTr("Delete %1?").arg(model.method)
                        standardButtons: Dialog.Ok | Dialog.Cancel
                        margins: 0

                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All related tasks will lose their method.")
                        }

                        onAccepted: {
                            TaskMethod.remove(model.task_method_id)
                            refresh();
                        }

                        onRejected: deleteDialog.close()
                    }
                }

                MyToolButton {
                    id: showButton
                    Layout.leftMargin: -28
                    Layout.rightMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    checkable: true
                    text: "\ue313"
                    rotation: checked ? 180 : 0
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: checked ? qsTr("Hide implements") : qsTr("Show implements")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                }
            }
        }
    }

    ListView {
        width: parent.width
        height: contentHeight
        visible: showButton.checked
        spacing: 0

        model: TaskImplementModel {
            id: taskImplementModel
            methodId: task_method_id
        }

        delegate: SettingsImplementDelegate {
            width: parent.width
            listPadding: control.listPadding
            onRefresh: { taskImplementModel.refreshRow(index); taskImplementModel.resetFilter() }
            firstColumnWidth: control.firstColumnWidth
            secondColumnWidth: control.secondColumnWidth
        }
    }

    FlatButton {
        visible: showButton.checked
        id: addVarietyButton
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        text: qsTr("Add implement")
        onClicked: addDialog.open();

        SimpleAddDialog {
            id: addDialog
            title: qsTr("Add implement")

            onAccepted: {
                TaskImplement.add({"implement" : text, "task_method_id" : model.task_method_id});
                taskImplementModel.refresh();
            }
        }
    }
}
