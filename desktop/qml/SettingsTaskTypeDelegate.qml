import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.croplan.components 1.0

Column {
    id: control
    
    property int firstColumnWidth
    property int secondColumnWidth
    
    signal refresh()
    
    Rectangle {
        color: Material.color(Material.Grey, Material.Shade100)
        width: parent.width
        height: childrenRect.height
        
        MouseArea {
            id: taskTypeMouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true
            
            RowLayout {
                id: headerRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Units.rowHeight
                spacing: Units.formSpacing
                
                TextInput {
                    text: type
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.leftMargin: Units.mediumSpacing
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
                    text: checked ?  "\ue313" : "\ue315"
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
        
        model: TaskMethodModel {
            id: taskImplementModel
            typeId: task_type_id
        }

        delegate: SettingsTaskMethodDelegate {
            width: parent.width
            onRefresh: taskImplementModel.refresh()
            firstColumnWidth: control.firstColumnWidth
            secondColumnWidth: control.secondColumnWidth
        }
    }
    
    Button {
        id: addMethodButton
        visible: showCropsButton.checked
        anchors.right: parent.right
        anchors.rightMargin: Units.mediumSpacing
        text: qsTr("Add method")
        flat: true
        Material.foreground: Material.accent
        onClicked: addDialog.open();
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Layout.rightMargin: Units.formSpacing

        SimpleAddDialog {
            id: addDialog
            title: qsTr("Add method")
            labelText: "Method"

            onAccepted: {
                TaskMethod.add({"method" : text,
                                "task_type_id" : model.task_type_id});

                taskImplementModel.refresh();
            }
        }


    }
}
