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

import io.croplan.components 1.0

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
        taskDialogHeader.typeField.setRowId(taskTypeId)
        taskDialogHeader.completedDate = Date.fromLocaleDateString(Qt.locale(),
                                                                   taskValueMap['completed_date'],
                                                                   "yyyy-MM-dd")
        taskForm.reset();
        taskForm.setFormValues(taskValueMap)
        dialog.open()
    }

    title: mode === "add" ? qsTr("Add Task") : qsTr("Edit Task")
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose
    Material.background: Material.color(Material.Grey, Material.Shade100)

    header: TaskDialogHeader {
        id: taskDialogHeader
        width: parent.width
        week: dialog.week
        year: dialog.year
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
    }

    footer: AddEditDialogFooter {
        height: childrenRect.height
        width: parent.width
        applyEnabled: formAccepted
        onRejected: dialog.reject();
        onAccepted: dialog.accept();
        mode: dialog.mode
    }

    onAccepted: {
        if (mode === "add") {
            var id = Task.add(taskForm.values)
        } else {
            var id = Task.update(dialog.taskId, taskForm.values)
            //TODO: task update
        }
    }
}
