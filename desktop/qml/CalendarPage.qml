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
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Page {
    id: page

    property alias week: weekSpinBox.week
    property alias year: weekSpinBox.year
    property alias rowsNumber: taskView.rowCount
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0

    title: qsTr("Task calendar")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    function refresh() {
        taskView.refresh();
    }

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 1 && addButton.visible && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextWeek()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousWeek()
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: weekSpinBox.previousYear();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 1 && !taskView.activeFocus && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: {
            taskView.currentIndex = 0
            taskView.forceActiveFocus();
        }
    }

    Shortcut {
        sequence: "Ctrl+J"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showDoneCheckBox.toggle();
    }

    Shortcut {
        sequence: "Ctrl+K"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showDueCheckBox.toggle();
    }

    Shortcut {
        sequence: "Ctrl+L"
        enabled: navigationIndex === 1 && !taskDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: showOverdueCheckBox.toggle();
    }

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
//        height: parent.height - 2 * Units.mediumSpacing
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        onAccepted: page.refresh()
        onApplied: page.refresh();
        week: page.week
        year: page.year
    }

    Platform.FileDialog {
        id: saveCalendarDialog

        defaultSuffix: "pdf"
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: {
            var month = -1
            var week = -1

            if (weekRadioButton.checked)
                week = MDate.currentWeek();
            else if (monthRadioButton.checked)
                month = MDate.currentMonth();

            Print.printCalendar(page.year, month, week, file, showOverdueCheckBox.checked)
        }
    }

    Settings {
        id: settings
        property bool showSeedCompanyBesideVariety
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
    }

    Pane {
        id: mainPane
        anchors.fill: parent
        padding: 0
        Material.elevation: 1

        Rectangle {
            id: buttonRectangle
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: Units.toolBarHeight

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: Units.formSpacing
                visible: !filterMode

                Label {
                    text: qsTr("%L1 task(s) selected", "", checks).arg(checks)
                    color: Material.color(Material.Blue)
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    visible: checks > 0
                    font.family: "Roboto Regular"
                    font.pixelSize: 16
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }

                FlatButton {
                    id: addButton
                    text: qsTr("Add task")
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    visible: checks === 0
                    highlighted: true
                    onClicked: taskDialog.addTask()
                }

                FlatButton {
                    id: templatesButton
                    text: qsTr("Templates")
                    font.pixelSize: Units.fontSizeBodyAndButton
                    visible: checks === 0
                    onClicked: {
                        mainPane.visible = false;
                        templatePane.visible = true;
                    }
                }

                SearchField {
                    id: filterField
                    placeholderText: qsTr("Search Tasks")
                    Layout.fillWidth: true
                    inputMethodHints: Qt.ImhPreferLowercase
                    visible: !checks
                }

                Row {
                    id: checkButtonRow
                    spacing: 0

                    ButtonCheckBox {
                        id: showDoneCheckBox
                        text: qsTr("Done")
                    }

                    ButtonCheckBox {
                        id: showDueCheckBox
                        checked: true
                        text: qsTr("Due")
                    }

                    ButtonCheckBox {
                        id: showOverdueCheckBox
                        text: qsTr("Overdue")
                        checked: false
                    }
                }

                WeekSpinBox {
                    id: weekSpinBox
                    week: MDate.currentWeek();
                    year: MDate.currentYear();
                }

                IconButton {
                    id: printButton
                    text: "\ue8ad"
                    hoverEnabled: true
                    visible: largeDisplay && checks == 0
                    //                    Layout.rightMargin: -padding*2
                    Layout.rightMargin: 16 - padding

                    ToolTip.visible: hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: qsTr("Print the task calendar")

                    onClicked: printDialog.open();

                    Dialog {
                        id: printDialog
                        title: qsTr("Print the task calendar")
                        width: 300
                        margins: 0

                        onAccepted: saveCalendarDialog.open()

                        ColumnLayout {
                            width: parent.width
                            spacing: -weekRadioButton.padding

                            RadioButton {
                                id: weekRadioButton
                                text: qsTr("Current week")
                                checked: true
                            }

                            RadioButton {
                                id: monthRadioButton
                                text: qsTr("Current month")
                            }

                            RadioButton {
                                id: yearRadioButton
                                text: qsTr("Current year")
                            }
                        }

                        footer: DialogButtonBox {
                            Button {
                                id: rejectButton
                                flat: true
                                text: qsTr("Cancel")
                                Material.foreground: Material.accent
                                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                            }

                            Button {
                                id: applyButton
                                Material.background: Material.accent
                                Material.foreground: "white"
                                text: qsTr("Print")

                                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                            }
                        }
                    }
                }

            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
            width: parent.width
        }

        Column {
            id: blankStateColumn
            z: 1
            spacing: Units.smallSpacing
            visible: !page.rowsNumber
            anchors {
                centerIn: parent
            }

            Label {
                id: emptyStateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (showDoneCheckBox.checked && showDueCheckBox.checked && showOverdueCheckBox.checked)
                        qsTr('No tasks done, due or overdue for week %1').arg(page.week)
                    else if (showDoneCheckBox.checked && showDueCheckBox.checked)
                        qsTr('No tasks done or due for week %1').arg(page.week)
                    else if (showDoneCheckBox.checked && showOverdueCheckBox.checked)
                        qsTr('No tasks done or overdue for week %1').arg(page.week)
                    else if (showDueCheckBox.checked && showOverdueCheckBox.checked)
                        qsTr('No tasks due or overdue for week %1').arg(page.week)
                    else if (showDueCheckBox.checked && showOverdueCheckBox.checked)
                        qsTr('No tasks due or overdue for week %1').arg(page.week)
                    else if (showDoneCheckBox.checked)
                        qsTr('No tasks done week %1').arg(page.week)
                    else if(showDueCheckBox.checked)
                        qsTr("No task due for week %1").arg(page.week)
                    else if (showOverdueCheckBox.checked)
                        qsTr("No tasks overdue for week %1").arg(page.week)
                    else
                        qsTr("No tasks to show")
                }
                font { family: "Roboto Regular"; pixelSize: Units.fontSizeTitle }
                color: Qt.rgba(0, 0, 0, 0.8)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: noneLabel
                visible: !showDoneCheckBox.checked && !showDueCheckBox.checked && !showOverdueCheckBox.checked
                anchors.horizontalCenter: parent.horizontalCenter
                text:  qsTr("Check at least one type to see them")
                font { family: "Roboto Regular"; pixelSize: Units.fontSizeBodyAndButton }
                color: Qt.rgba(0, 0, 0, 0.6)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: qsTr("Add")
                flat: true
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                Material.background: Material.accent
                Material.foreground: "white"
                font.pixelSize: Units.fontSizeBodyAndButton
                onClicked: taskDialog.addTask()
            }
        }

        TaskView {
            id: taskView
            width: Math.min(1200, parent.width * 0.8)
            anchors {
                top: topDivider.bottom
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                topMargin: Units.smallSpacing
                bottomMargin: Units.smallSpacing
            }
            ScrollBar.vertical: ScrollBar {
                parent: taskView.parent
                anchors {
                    top: parent.top
                    topMargin: buttonRectangle.height + topDivider.height
                    right: parent.right
                    bottom: parent.bottom
                }
            }
            year: weekSpinBox.year
            week: weekSpinBox.week
            showDone: showDoneCheckBox.checked
            showDue: showDueCheckBox.checked
            showOverdue: showOverdueCheckBox.checked
            filterString: filterField.text
        }
    }

    TemplatePane {
        id: templatePane
        visible: false
        anchors.fill: parent

        onGoBack:  {
            mainPane.visible = true;
            templatePane.visible = false;
            page.refresh();
        }
    }
}
