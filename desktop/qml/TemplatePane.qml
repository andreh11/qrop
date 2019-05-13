/*
 * Copyright (C) 2018-2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Pane {
    id: pane

    property int taskTemplateId: -1
    property string taskTemplateName: ""

    signal goBack()

    function refresh() {
        taskTemplateModel.refresh();
        beforeGHModel.refresh();
        afterGHModel.refresh();
        beforePlantingModel.refresh();
        afterPlantingModel.refresh();
        beforeFirstHarvestModel.refresh();
        afterFirstHarvestModel.refresh();
        beforeLastHarvestModel.refresh();
        afterLastHarvestModel.refresh();
    }

    padding: 0
    Material.background: "white"
    Material.elevation: 0

    TemplateTaskModel {
        id: beforeGHModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 1
        beforeDate: true
    }

    TemplateTaskModel {
        id: afterGHModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 1
        beforeDate: false
    }

    TemplateTaskModel {
        id: beforePlantingModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 0
        beforeDate: true
    }

    TemplateTaskModel {
        id: afterPlantingModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 0
        beforeDate: false
    }

    TemplateTaskModel {
        id: beforeFirstHarvestModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 2
        beforeDate: true
    }

    TemplateTaskModel {
        id: afterFirstHarvestModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 2
        beforeDate: false
    }

    TemplateTaskModel {
        id: beforeLastHarvestModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 2
        beforeDate: true
    }

    TemplateTaskModel {
        id: afterLastHarvestModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 2
        beforeDate: false
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            id: templateColumn
            spacing: 0
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width/3

            Item {
                id: templateButtonRectangle
                //                color: "white"
                visible: true
                Layout.fillWidth: true
                height: Units.toolBarHeight

                ToolButton {
                    id: backButton
                    text: "\ue5c4" // arrow_back
                    Material.foreground: Material.Grey
                    font.family: "Material Icons"
                    font.pixelSize: Units.fontSizeHeadline
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    onClicked: pane.goBack()
                }

                Button {
                    id: addButton
                    text: qsTr("Add template")
                    flat: true
                    font.pixelSize: Units.fontSizeBodyAndButton
                    highlighted: true
                    Layout.alignment: Qt.AlignRight
                    anchors.right: parent.right
                    anchors.rightMargin: 16 - ((background.width - contentItem.width) / 4)
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: templateMouseArea
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onPressed: mouse.accepted = false
                    }
                    onClicked: addTemplateDialog.open()

                    SimpleAddDialog {
                        id: addTemplateDialog
                        title: qsTr("Add template")
                        onAccepted: {
                            TaskTemplate.add({"name": text});
                            taskTemplateModel.refresh();
                        }
                    }
                }
            }

            ThinDivider { Layout.fillWidth: true }

            Pane {
                id: templatePane
                Layout.fillHeight: true
                Layout.fillWidth: true
                Material.background: "white"

                ListView {
                    id: templateView
                    anchors.fill: parent
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

                    focus: true
                    delegate: Rectangle {
                        id: delegate
                        //                        onClicked: templatePane.taskTemplateId = task_template_id
                        width: parent.width
                        height: Units.rowHeight

                        MouseArea {
                            id: templateRowMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            preventStealing: true
                            propagateComposedEvents: true
                            //                    z: 3
                            //                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                templateView.currentIndex = index
                                pane.taskTemplateId = task_template_id
                                pane.taskTemplateName = name
                            }

                            onDoubleClicked: {
                                taskNameLabel.visible = false;
                                taskNameField.visible = true;
                                taskNameField.forceActiveFocus();
                            }

                            Label {
                                id: taskNameLabel
                                text: taskNameField.text
                                elide: Text.ElideRight
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton

                                anchors {
                                    left: parent.left
                                    leftMargin: Units.smallSpacing
                                    right: parent.right
                                    rightMargin: anchors.leftMargin
                                    verticalCenter: parent.verticalCenter
                                }
                            }

                            TextField {
                                id: taskNameField
                                visible: false
                                text: name
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton

                                anchors {
                                    left: parent.left
                                    leftMargin: Units.smallSpacing
                                    right: parent.right
                                    rightMargin: anchors.leftMargin
                                    verticalCenter: parent.verticalCenter
                                }

                                onEditingFinished: {
                                    TaskTemplate.update(task_template_id, {"name": text});
                                    taskNameField.visible = false;
                                    taskNameLabel.visible = true;
                                    taskTemplateModel.refresh();
                                }
                                Keys.onEscapePressed: {
                                    text = name;
                                    taskNameLabel.visible = true;
                                    taskNameField.visible = false;
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
            }
        }

        VerticalThinDivider { Layout.fillHeight: true }

        ColumnLayout {
            id: taskColumn
            spacing: 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 2*parent.width/3

            Rectangle {
                id: taskButtonRectangle
                width: parent.width
                height: Units.toolBarHeight
                color: "white"
                Layout.fillWidth: true

                Label {
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    text: qsTr("Template %1").arg(pane.taskTemplateName)
                    Layout.alignment: Qt.AlignLeft

                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                }

                Button {
                    id: addTaskButton
                    flat: true
                    highlighted: true
                    text: qsTr("Add task")
                    z: 1
                    onClicked: addTemplateTaskDialog.open();
                    anchors {
                        right: parent.right
                        rightMargin: 16 - ((background.width - contentItem.width) / 4)
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            ThinDivider { Layout.fillWidth: true }

            TaskDialog {
                id: addTemplateTaskDialog
                mode: "add"
                templateMode: true
                taskTemplateId: pane.taskTemplateId
                width: parent.width / 2
                height: parent.height
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                week: 0
                year: 0
                onAccepted: pane.refresh();
            }

            Pane {
                id: taskPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Material.background: Material.color(Material.Grey, Material.Shade100)

                ScrollView {
                    id: scrollView
                    clip: true
                    padding: 0
                    anchors.fill: parent
                    contentHeight: taskListColumn.implicitHeight
                    contentWidth: taskListColumn.implicitWidth

                    Column {
                        id: taskListColumn
                        spacing: 4
                        leftPadding: scrollView.width * 0.1
                        rightPadding: leftPadding
                        width: scrollView.width - rightPadding - leftPadding
                        anchors.horizontalCenter: scrollView.horizontalCenter

                        Repeater {
                            model: [beforeGHModel]
                            TemplateListView {
                                model: modelData
                                width: parent.width
                                Layout.fillWidth: true

                                onEditTask: {
                                    addTemplateTaskDialog.editTask(taskId)
                                    pane.refresh();
                                }
                                onDeleteTask: {
                                    Task.remove(taskId);
                                    pane.refresh();
                                }
                                onDuplicateTask: {
                                    Task.duplicate(taskId);
                                    pane.refresh();
                                }
                            }
                        }

                        TemplateDateSection {
                            text: qsTr("Greenhouse sowing")
                            width: parent.width
                            visible: beforeGHModel.rowCount || afterGHModel.rowCount
                        }

                        Repeater {
                            model: [afterGHModel, beforePlantingModel]
                            TemplateListView {
                                model: modelData
                                width: parent.width
                                Layout.fillWidth: true

                                onEditTask: {
                                    addTemplateTaskDialog.editTask(taskId)
                                    pane.refresh();
                                }
                                onDeleteTask: {
                                    Task.remove(taskId);
                                    pane.refresh();
                                }
                                onDuplicateTask: {
                                    Task.duplicate(taskId);
                                    pane.refresh();
                                }
                            }
                        }

                        TemplateDateSection {
                            text: qsTr("Sowing/planting ")
                            width: parent.width
                            visible: beforePlantingModel.rowCount || afterPlantingModel.rowCount
                        }

                        Repeater {
                            model: [afterPlantingModel, beforeFirstHarvestModel]
                            TemplateListView {
                                model: modelData
                                width: parent.width
                                Layout.fillWidth: true

                                onEditTask: {
                                    addTemplateTaskDialog.editTask(taskId)
                                    pane.refresh();
                                }
                                onDeleteTask: {
                                    Task.remove(taskId);
                                    pane.refresh();
                                }
                                onDuplicateTask: {
                                    Task.duplicate(taskId);
                                    pane.refresh();
                                }
                            }
                        }

                        TemplateDateSection {
                            text: qsTr("First harvest")
                            width: parent.width
                            visible: beforeFirstHarvestModel.rowCount || afterFirstHarvestModel.rowCount
                        }

                        Repeater {
                            model: [afterFirstHarvestModel, beforeLastHarvestModel]
                            TemplateListView {
                                model: modelData
                                width: parent.width
                                Layout.fillWidth: true

                                onEditTask: {
                                    addTemplateTaskDialog.editTask(taskId)
                                    pane.refresh();
                                }
                                onDeleteTask: {
                                    Task.remove(taskId);
                                    pane.refresh();
                                }
                                onDuplicateTask: {
                                    Task.duplicate(taskId);
                                    pane.refresh();
                                }
                            }
                        }

                        TemplateDateSection {
                            text: qsTr("Last harvest")
                            width: parent.width
                            visible: beforeLastHarvestModel.rowCount || afterLastHarvestModel.rowCount
                        }

                        Repeater {
                            model: [afterLastHarvestModel]
                            TemplateListView {
                                model: modelData
                                width: parent.width
                                Layout.fillWidth: true

                                onEditTask: {
                                    addTemplateTaskDialog.editTask(taskId)
                                    pane.refresh();
                                }
                                onDeleteTask: {
                                    Task.remove(taskId);
                                    pane.refresh();
                                }
                                onDuplicateTask: {
                                    Task.duplicate(taskId);
                                    pane.refresh();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
