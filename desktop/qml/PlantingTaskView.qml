import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

ListView {
    id: taskView

    property alias week: taskModel.week
    property alias year: taskModel.year
    property alias showDone: taskModel.showDone
    property alias showOverdue: taskModel.showOverdue
    property alias showDue: taskModel.showDue
    property alias filterString: taskModel.filterString
    property var activeCompleteButton: taskView.currentItem
    property alias rowCount: taskModel.rowCount
    property alias plantingId: taskModel.plantingId
    property int taskTemplateId: -1

    function refresh() {
        // Save current position, because refreshing the model will cause reloading,
        // and view position will be reset.
        var currentY = taskView.contentY
        taskModel.refresh();
        taskView.contentY = currentY
    }

    clip: true
    spacing: 4
    cacheBuffer: Units.rowHeight*2

    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        visible: taskView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    Keys.onSpacePressed: {
        if (event.modifiers & Qt.ControlModifier)
            currentItem.completeButton.pressAndHold()
        else
            currentItem.completeButton.clicked()
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_E)
            currentItem.editTask()
        if (event.key === Qt.Key_D)
            currentItem.detailsButton.toggle()
    }

    ScrollBar.vertical: ScrollBar { }

    Popup {
        id: calendarPopup
        property int taskId: -1

        y: taskView.activeCompleteButton ? taskView.activeCompleteButton.y : 0
        x: taskView.activeCompleteButton ? taskView.activeCompleteButton.x : 0
        width: contentItem.width
        height: contentItem.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        margins: 0

        contentItem: CalendarView {
            id: calendarView

            clip: true
            year: taskView.year
            month: (new Date()).getMonth()

            onDateSelect: {
                calendarPopup.close();
                Task.completeTask(calendarPopup.taskId, newDate)
                taskView.refresh();
            }
        }
    }

    model: TaskModel {
        id: taskModel
    }

    delegate: Rectangle {
        id: delegate

        property alias completeButton: completeButton
        property alias forwardDelayButton: forwardDelayButton
        property alias backwardDelayButton: backwardDelayButton
        property alias deleteButton: deleteButton
        property bool inTemplate: taskTemplateId > 0 && model.task_template_id === taskTemplateId

        function editTask() {
            taskDialog.editTask(model.task_id)
        }

        function labelText() {
            var planting_ids = model.plantings.split(',')
            var planting_id = Number(planting_ids[0])
            var map = Planting.mapFromId("planting_view", planting_id);
            var length = map['length']
            var rows = map['rows']
            var spacingPlants = map['spacing_plants']
            var seedsPerHole = map['seeds_per_hole']

            if (task_type_id === 1 || task_type_id === 3) {
                if (settings.useStandardBedLength) {
                    var beds = Number(length/settings.standardBedLength)
                    return qsTr("%L1 bed @ ", "", beds).arg(beds) + qsTr("%L1 rows X %L2 cm").arg(rows).arg(spacingPlants)
                } else {
                    return qsTr("%L1 bed m @ %L2 rows X %L3 cm").arg(length).arg(rows).arg(spacingPlants)
                }
            } else if (task_type_id === 2) {
                var traysToStart = Math.round(Number(map['trays_to_start']) * 100)/100
                var traySize = map["tray_size"];
                if (seedsPerHole > 1)
                    return qsTr("%L1 trays of %L2 @ %L3 seeds").arg(traysToStart).arg(traySize).arg(seedsPerHole)
                else
                    return qsTr("%L1 trays of %L2").arg(traysToStart).arg(traySize)

            } else {
                return qsTr("%1%2%3").arg(model.method).arg(model.implement ? ", " : "").arg(model.implement)
            }
        }

        height: summaryRow.height
        width: parent.width
        color: "white"
        //        enabled: inTemplate
        radius: 2

        Rectangle {
            id: highlightRectangle
            anchors.fill: parent
            visible: rowMouseArea.containsMouse || inTemplate
            z:3;
            opacity: 0.1;
            color: Material.primary
            radius: 2
        }

        MouseArea {
            id: rowMouseArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onClicked: editTask()

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
                    topMargin: delegate.border.width
                    bottomMargin: delegate.border.width
                    rightMargin: delegate.border.width
                }

                Row {
                    spacing: -16
                    anchors.verticalCenter: parent.verticalCenter

                    MyToolButton {
                        id: backwardDelayButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !model.done
                        text: "\ue314"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        onClicked: {
                            Task.delay(model.task_id, -1);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Move to previous week")
                        ToolTip.visible: hovered
                    }

                    MyToolButton {
                        id: forwardDelayButton
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pointSize: Units.fontSizeBodyAndButton
                        visible: !model.done
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            Task.delay(model.task_id, 1);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Move to next week")
                        ToolTip.visible: hovered
                    }

                    MyToolButton {
                        id: deleteButton
                        text: enabled ? "\ue872" : ""
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: model.task_type_id > 3
                        onClicked: {
                            Task.remove(model.task_id);
                            taskView.refresh();
                        }
                        ToolTip.text: qsTr("Remove")
                        ToolTip.visible: hovered
                    }
                }
            }

            RowLayout {
                id: summaryRow
                height: Units.rowHeight
                width: parent.width
                spacing: Units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter

                TaskCompleteButton {
                    id: completeButton
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    width: height
                    overdue: model.overdue
                    done: model.done
                    due: model.due
                    //                    Layout.leftMargin: -completeButton.padding/2
                    //                    Layout.rightMargin: Layout.leftMargin

                    ToolTip.text:
                        done ? qsTr("Done on %1. Click to undo."
                                    .arg(model.completed_date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)))
                             : qsTr("Click to complete task. Hold to select date.")
                    ToolTip.visible: hovered

                    onClicked: {
                        if (done)
                            Task.uncompleteTask(model.task_id);
                        else
                            Task.completeTask(model.task_id);
                        taskView.refresh();
                    }
                    onPressAndHold: {
                        taskView.currentIndex = index
                        calendarPopup.taskId = model.task_id
                        calendarPopup.open()
                    }
                }

                Column {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                    Label {
                        text: model.type
                        elide: Text.ElideRight
                        width: parent.width
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        color: enabled ? Units.colorHighEmphasis : Units.colorDisabledEmphasis
                    }
                    Label {
                        text: labelText()
                        elide: Text.ElideRight
                        width: parent.width
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeCaption
                        color: enabled ? Units.colorMediumEmphasis : Units.colorDisabledEmphasis
                    }
                }

                Label {
                    text: model.template_task_id > 0 ? "\ue157" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 20
                }

                Label {
                    text: MDate.isoWeek(model.assigned_date) !== week
                          ? MDate.formatDate(model.assigned_date, year, "")
                          : MDate.shortDayName(model.assigned_date)
                    elide: Text.ElideRight
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    Layout.rightMargin: Units.smallSpacing
                }
            }
        }
    }
}
