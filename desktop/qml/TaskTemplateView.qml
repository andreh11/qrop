import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

ListView {
    id: templateView

    function refresh() {
        taskTemplateModel.refresh();
    }

    model: TaskTemplateModel {
        id: taskTemplateModel
    }
    
    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        //                        visible: taskView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }
    
    onCurrentIndexChanged: currentItem.setTemplate()
    
    focus: true
    delegate: Rectangle {
        id: delegate
        
        function setTemplate() {
            pane.taskTemplateId = task_template_id
            pane.taskTemplateName = name
        }
        
        //                        onClicked: templatePane.taskTemplateId = task_template_id
        width: parent.width
        height: Units.rowHeight
        
        MouseArea {
            id: templateRowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: true
            
            onClicked: templateView.currentIndex = index
            
            onDoubleClicked: {
                taskNameLabel.state = "edit"
            }
            
            EditableLabel {
                id: taskNameLabel
                text: name
                anchors {
                    left: parent.left
                    leftMargin: Units.smallSpacing
                    right: parent.right
                    rightMargin: anchors.leftMargin
                    verticalCenter: parent.verticalCenter
                }
                onEditingFinished: {
                    TaskTemplate.update(task_template_id, {"name": text});
                    pane.refresh();
                }
            }
            
            Rectangle {
                //                                id: taskButtonRectangle
                height: Units.rowHeight
                width: childrenRect.width
                color: "white"
                z: 2
                visible: templateRowMouseArea.containsMouse
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: delegate.border.width
                    bottomMargin: delegate.border.width
                    rightMargin: delegate.border.width
                }
                
                Row {
                    spacing: -16
                    anchors.verticalCenter: parent.verticalCenter
                    
                    MyToolButton {
                        id: duplicateTemplateButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !model.done
                        text: "\ue14d"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        onClicked: {
                            TaskTemplate.duplicate(task_template_id);
                            pane.refresh();
                        }
                        ToolTip.text: qsTr("Duplicate template")
                        ToolTip.visible: hovered
                    }
                    
                    MyToolButton {
                        id: deleteTemplateButton
                        text: enabled ? "\ue872" : ""
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        visible: !model.done
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            TaskTemplate.remove(task_template_id);
                            updateTaskDialog.open();
                            pane.refresh();
                        }
                        ToolTip.text: qsTr("Delete template")
                        ToolTip.visible: hovered
                    }
                    
                }
            }
        }
    }
}
