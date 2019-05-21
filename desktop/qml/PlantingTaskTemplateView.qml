import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

ListView {
    id: templateView

    property alias plantingId: taskTemplateModel.plantingId
    property int taskTemplateId: -1
    property string taskTemplateName: ""

    signal templateListChanged()

    function refresh() {
        taskTemplateModel.refresh();
        currentIndexChanged();
    }

    onPlantingIdChanged: {
        templateView.currentIndex = -1;
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

    onCurrentIndexChanged: {
        if (currentIndex == -1) {
            templateView.taskTemplateId = -1
            templateView.taskTemplateName = ""
        } else {
            currentItem.setTemplate();
        }
    }

    focus: true
    delegate: Rectangle {
        id: delegate

        function setTemplate() {
            templateView.taskTemplateId = task_template_id
            templateView.taskTemplateName = name
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

            onClicked: {
                if (!model.is_applied)
                    return;

                if (templateView.currentIndex == index)
                    templateView.currentIndex = -1;
                else
                    templateView.currentIndex = index
            }

            Row {
                anchors {
                    left: parent.left
                    leftMargin: Units.smallSpacing
                    right: parent.right
                    rightMargin: anchors.leftMargin
                    verticalCenter: parent.verticalCenter
                }

                CheckBox {
                    id: checkBox
                    anchors.verticalCenter: parent.verticalCenter
                    checked: is_applied
                    onToggled: {
                        taskTemplateModel.toggle(index);
                        templateListChanged();
                    }
                }

                Label {
                    id: taskNameLabel
                    text: name
                    elide: Text.ElideRight
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
