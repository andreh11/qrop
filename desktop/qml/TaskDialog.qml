/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Dialog {
    id: dialog

    property int taskId: -1
    property int week
    property int year
    property string mode: "add"
    property alias form: taskForm
    property alias formAccepted: taskForm.accepted
    property var taskValueMap: Task.mapFromId("task_view", taskId)
    property int taskTypeId: Number(taskValueMap['task_type_id'])
    property bool sowPlantTask: mode === "edit" && dialog.taskTypeId <= 3

    function reset() {
        taskDialogHeader.reset();
        taskForm.reset();
    }

    function addTask() {
        mode = "add";
        dialog.taskId = -1
        taskDialogHeader.reset();
        taskForm.reset()
        dialog.open()
    }

    function editTask(taskId) {
        mode = "edit";
        dialog.taskId = taskId;
        taskIdChanged(); // To update taskValueMap

        taskDialogHeader.reset();

        var typeName = TaskType.mapFromId(taskTypeId)["type"];
        taskDialogHeader.typeField.selectedId = taskTypeId;
        taskDialogHeader.typeField.text = typeName;

        taskDialogHeader.completedDate = taskValueMap['completed_date']
        taskForm.reset();
        taskForm.setFormValues(taskValueMap)
        dialog.open();
    }

    onOpened: if (mode === "add") taskDialogHeader.typeField.forceActiveFocus();

    title: mode === "add" ? qsTr("Add Task") : qsTr("Edit Task")
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape
    Material.background: Material.color(Material.Grey, Material.Shade100)
    height: sowPlantTask ? taskForm.implicitHeight + Units.smallSpacing : parent.height - 2 * Units.smallSpacing

    Shortcut {
        sequences: ["Ctrl+Enter", "Ctrl+Return"]
        enabled: dialog.visible
        context: Qt.ApplicationShortcut
        onActivated: {
            if (taskForm.accepted) accept();
        }
    }

    header: TaskDialogHeader {
        id: taskDialogHeader
        width: parent.width
        week: dialog.week
        year: dialog.year
        sowPlantTask: dialog.mode === "edit" && dialog.taskTypeId <= 3
    }

    TaskForm {
        id: taskForm
        anchors.fill: parent
        taskTypeId: taskDialogHeader.taskTypeId
        taskValueMap: dialog.taskValueMap
        completedDate: taskDialogHeader.completedDate
        week: dialog.week
        year: dialog.year
        taskId: dialog.taskId
        mode: dialog.mode
        sowPlantTask: dialog.mode === "edit" && dialog.taskTypeId <= 3
    }

    footer: AddEditDialogFooter {
        applyEnabled: formAccepted
        mode: dialog.mode
    }


    onAccepted: {
        if (mode === "add") {
            console.log(taskForm.values["task_implement_id"]);
            Task.add(taskForm.values);
        } else {
            Task.update(dialog.taskId, taskForm.values);
        }
    }
}
