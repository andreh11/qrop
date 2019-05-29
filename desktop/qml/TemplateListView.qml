/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

ListView {
    id: listView

    signal editTask(int taskId)
    signal deleteTask(int taskId)
    signal duplicateTask(int taskId)

    implicitHeight: contentHeight
    spacing: 4
    cacheBuffer: Units.rowHeight*2
    boundsBehavior: Flickable.StopAtBounds

    delegate: Rectangle {
        id: listDelegate
        implicitHeight: column.implicitHeight
        color: "white"
        width: parent.width
        border.color: Material.color(Material.Grey, Material.Shade400)
        border.width: rowMouseArea.containsMouse ? 1 : 0

        MouseArea {
            id: rowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onClicked: editTask(template_task_id)

            Rectangle {
                id: taskButtonRectangle
                height: Units.rowHeight
                width: childrenRect.width
                color: "white"
                z: 2
                visible: rowMouseArea.containsMouse
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: listDelegate.border.width
                    bottomMargin: listDelegate.border.width
                    rightMargin: listDelegate.border.width
                }

                Row {
                    spacing: -16
                    anchors.verticalCenter: parent.verticalCenter

                    MyToolButton {
                        id: editTaskButton
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\ue254"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        onClicked: editTask(template_task_id)
                        ToolTip.text: qsTr("Edit task")
                        ToolTip.visible: hovered
                    }

                    MyToolButton {
                        id: duplicateTaskButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !model.done
                        text: "\ue14d"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateTask(template_task_id)
                        ToolTip.text: qsTr("Duplicate template")
                        ToolTip.visible: hovered
                    }

                    MyToolButton {
                        id: deleteTaskButton
                        text: enabled ? "\ue872" : ""
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: deleteTask(template_task_id)
                        ToolTip.text: qsTr("Delete task")
                        ToolTip.visible: hovered
                    }
                }
            }

            Column {
                id: column
                width: parent.width
                padding: Units.smallSpacing

                Label {
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    color: Units.colorHighEmphasis
                    text: {
                        if (type && method && implement)
                            qsTr("%1, %2, %3").arg(type).arg(method).arg(implement)
                        else if (type && method)
                            qsTr("%1, %2").arg(type).arg(method)
                        else
                            qsTr("%1").arg(type)
                    }
                }

                Label {
                    readonly property string dayString: {
                        if (link_days == 0)
                            qsTr("Same day")
                        else if (link_days > 0)
                            qsTr("%L1 days after").arg(link_days)
                        else
                            qsTr("%L1 days before").arg(link_days * -1)
                    }

                    text: "%1%2".arg(dayString).arg(description.trim() ? ", %1".arg(description.trim())
                                                                       : "")
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeCaption
                    color: Units.colorMediumEmphasis
                }
            }
        }
    }
}
