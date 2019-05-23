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

    signal goBack

    function refresh() {
        templateView.refresh();
        beforeGHModel.refresh();
        afterGHModel.refresh();
        beforePlantingModel.refresh();
        afterPlantingModel.refresh();
        beforeFirstHarvestModel.refresh();
        afterFirstHarvestModel.refresh();
        beforeLastHarvestModel.refresh();
        afterLastHarvestModel.refresh();
        templateView.currentIndexChanged();
    }

    function editTask(taskId) {
        taskDialog.editTask(taskId)
        pane.refresh();
    }

    function removeTask(taskId) {
        removeTaskDialog.taskId = taskId
        removeTaskDialog.open();
    }

    function duplicateTask(taskId) {
        var newId = TemplateTask.duplicate(taskId);
        addTaskDialog.taskId = newId;
        addTaskDialog.open();
        pane.refresh();
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
        templateDateType: 3
        beforeDate: true
    }

    TemplateTaskModel {
        id: afterLastHarvestModel
        taskTemplateId: pane.taskTemplateId
        templateDateType: 3
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
                    onClicked: addTemplateDialog.open();

                    SimpleAddDialog {
                        id: addTemplateDialog
                        title: qsTr("Add template")
                        onAccepted: {
                            TaskTemplate.add({"name": text});
                            templateView.refresh();
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

                TaskTemplateView {
                    id: templateView
                    anchors.fill: parent
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
                    onClicked: taskDialog.addTask();
                    anchors {
                        right: parent.right
                        rightMargin: 16 - ((background.width - contentItem.width) / 4)
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            ThinDivider { Layout.fillWidth: true }

            Pane {
                id: taskPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Material.background: Material.color(Material.Grey, Material.Shade100)

                TaskDialog {
                    id: taskDialog
                    mode: "add"
                    templateMode: true
                    taskTemplateId: pane.taskTemplateId
                    width: parent.width / 2
                    //                height: parent.height
                    //                    x: (parent.width - width) / 2
                    //                    y: (parent.height - height) / 2
                    week: 0
                    year: 0
                    onAccepted: {
                        updateDialog.open();
                        pane.refresh();
                    }
                }

                Dialog {
                    id: addTaskDialog
                    property int taskId: -1
                    title: qsTr("Add this task to all current applications of this template?")
                    standardButtons: Dialog.No | Dialog.Yes
                    onAccepted: TemplateTask.addToCurrentApplications(taskId)
                }

                Dialog {
                    id: removeTaskDialog
                    property int taskId: -1
                    title: qsTr("Remove this task from all current applications of this template?")
                    standardButtons: Dialog.No | Dialog.Yes
                    onAccepted: {
                        TemplateTask.removeFromCurrentApplications(taskId)
                        TemplateTask.remove(taskId);
                        pane.refresh();
                    }
                    onRejected: {
                        TemplateTask.remove(taskId);
                        pane.refresh();
                    }
                }

                Dialog {
                    id: updateDialog
                    property int taskId: -1
                    title: qsTr("Apply update to all current applications of this template?")
                    standardButtons: Dialog.No | Dialog.Apply

                    onAccepted: console.log("Ok clicked")
                    onRejected: console.log("Cancel clicked")
                }

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

                                onEditTask: pane.editTask(taskId)
                                onDeleteTask: pane.removeTask(taskId)
                                onDuplicateTask: pane.duplicateTask(taskId)
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
                                onEditTask: pane.editTask(taskId)
                                onDeleteTask: pane.removeTask(taskId)
                                onDuplicateTask: pane.duplicateTask(taskId)
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
                                onEditTask: pane.editTask(taskId)
                                onDeleteTask: pane.removeTask(taskId)
                                onDuplicateTask: pane.duplicateTask(taskId)
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
                                onEditTask: pane.editTask(taskId)
                                onDeleteTask: pane.removeTask(taskId)
                                onDuplicateTask: pane.duplicateTask(taskId)
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
                                onEditTask: pane.editTask(taskId)
                                onDeleteTask: pane.removeTask(taskId)
                                onDuplicateTask: pane.duplicateTask(taskId)
                            }
                        }
                    }
                }
            }
        }
    }
}
