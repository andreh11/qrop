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
    property bool shortcutEnabled: navigationIndex === 1 && !taskDialog.activeFocus

    title: qsTr("Task calendar")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    function refresh() {
        taskView.refresh();
    }

    function doPrint(file) {
        let week = weekRadioButton.checked ? page.week : -1;
        let month = monthRadioButton.checked ? QrpDate.month(QrpDate.mondayOfWeek(page.week, page.year)) : -1;
        console.log("month", month, "week", week);
        Print.printCalendar(page.year, month, week, file, showDoneCheckBox.checked, showDueCheckBox.checked, showOverdueCheckBox.checked)
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
                    }
                }

                WeekSpinBox {
                    id: weekSpinBox
                    week: QrpDate.currentWeek();
                    year: QrpDate.currentYear();
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

                        onAccepted: {
                            if (BuildInfo.isMobileDevice())
                                saveCalendarMobileDialog.open();
                            else
                                saveCalendarDialog.open();
                        }

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

    // Dialogs

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
//        height: parent.height/2
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
        folder: Qt.resolvedUrl(window.lastFolder)
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: doPrint(file);
    }

    MobileFileDialog {
        id: saveCalendarMobileDialog

        title: qsTr("Print the task calendar")
        text: qsTr("Please type a name for the PDF.")
        acceptText: qsTr("Print")

        x: page.width - width
        y: buttonRectangle.height

        nameField.visible : true;
        combo.visible : false;

        onAccepted: {
            //MB_TODO: check if the file already exist? shall we overwrite or discard?
            doPrint('file://%1/%2.pdf'.arg(FileSystem.pdfPath).arg(nameField.text));
        }
    }

    // Shortcuts

    ApplicationShortcut {
        sequences: ["Ctrl+N"]; enabled: shortcutEnabled && addButton.visible; onActivated: addButton.clicked()
    }

    ApplicationShortcut {
        sequences: [StandardKey.Find]; enabled: shortcutEnabled; onActivated: filterField.forceActiveFocus();
    }

    ApplicationShortcut {
        sequence: "Ctrl+Right"; enabled: shortcutEnabled; onActivated: weekSpinBox.nextWeek()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Left"; enabled: shortcutEnabled; onActivated: weekSpinBox.previousWeek()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Up"; enabled: shortcutEnabled; onActivated: weekSpinBox.nextYear()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Down"; enabled: shortcutEnabled; onActivated: weekSpinBox.previousYear()
    }

    ApplicationShortcut {
        sequence: "Ctrl+J"; enabled: shortcutEnabled; onActivated: showDoneCheckBox.toggle();
    }

    ApplicationShortcut {
        sequence: "Ctrl+K"; enabled: shortcutEnabled; onActivated: showDueCheckBox.toggle();
    }

    ApplicationShortcut {
        sequence: "Ctrl+L"; enabled: shortcutEnabled; onActivated: showOverdueCheckBox.toggle();
    }

    ApplicationShortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: shortcutEnabled && !taskView.activeFocus
        onActivated: {
            taskView.currentIndex = 0
            taskView.forceActiveFocus();
        }
    }
}
