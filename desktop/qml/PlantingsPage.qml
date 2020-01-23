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
import QtCharts 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Page {
    id: page

    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property alias filterString: filterField.text
    property alias year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property date todayDate: new Date()
    property alias searchField: filterField

    property alias model: plantingsView.model
    property alias rowCount: plantingsView.rowCount
    property alias selectedIds: plantingsView.selectedIds
    property alias checks: plantingsView.checks
    property alias dialogOpened: plantingDialog.opened

    signal noteButtonClicked(int plantingId)

    function refresh() {
        plantingsView.refresh();
        taskSideSheet.refresh();
        chartPane.refresh();
    }

    function selectedIdList() {
        var idList = []
        for (var key in selectedIds)
            if (selectedIds[key])
                idList.push(key)
        return idList;
    }

    function duplicateSelected() {
        var idList = selectedIdList();
        Planting.duplicateList(idList)
        plantingsView.unselectAll()
        page.refresh()
        plantingsView.selectedIdsChanged();
    }

    function duplicateSelectedNextYear() {
        var idList = selectedIdList();
        Planting.duplicateListToYear(idList, year + 1)
        plantingsView.unselectAll()
        page.refresh()
        plantingsView.selectedIdsChanged();
    }

    function removeSelected() {
        var ids = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
                selectedIds[key] = false
                ids.push(key)
            }
        Planting.removeList(ids)
        page.refresh()
        plantingsView.selectedIdsChanged()
    }

    title: qsTr("Plantings")
    padding: 0
    Material.background: "white"

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 0 && addButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: ["Ctrl+T"]
        enabled: navigationIndex === 0 && addButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: timegraphButton.toggle();
    }


    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 0 && filterField.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+E"
        enabled: navigationIndex === 0 && editButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: editButton.clicked()
    }

    Shortcut {
        sequence: "Ctrl+D"
        enabled: navigationIndex === 0 && duplicateButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: duplicateButton.clicked()
    }

    Shortcut {
        sequence: StandardKey.Delete
        enabled: navigationIndex === 0 && deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: deleteButton.clicked()
    }

    Shortcut {
        sequence: StandardKey.SelectAll
        enabled: navigationIndex === 0 && !deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: plantingsView.selectAll();
    }

    Shortcut {
        sequence: StandardKey.Deselect
        enabled: navigationIndex === 0 && deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: plantingsView.unselectAll()
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 0 && !deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.nextSeason()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 0 && !deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.previousSeason();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 0 && !plantingsView.activeFocus && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: {
            plantingsView.currentIndex = 0
            plantingsView.forceActiveFocus();
        }
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 0 && !deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 0 && !deleteButton.visible && !dialogOpened
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.previousYear();
    }

    PlantingDialog {
        id: plantingDialog
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        height: parent.height - 2 * Units.smallSpacing
        model: plantingsView.model
        currentYear: page.year
        onPlantingsAdded: {
            addPlantingSnackbar.successions = successions;
            addPlantingSnackbar.open();
            page.refresh();
        }

        onPlantingsModified: {
            editPlantingsSnackBar.successions = successions;
            editPlantingsSnackBar.open();
            plantingsView.unselectAll();
            taskSideSheet.refresh();
            page.refresh();
        }

        onRejected: plantingsView.unselectAll()
    }

    Snackbar {
        id: addPlantingSnackbar

        property int successions: 0

        z: 2
        x: parent.width/2 - width/2
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Added %L1 planting(s)", "", successions).arg(successions)
        visible: false

        onClicked: {
            Planting.rollback();
            page.refresh();
        }
    }


    Snackbar {
        id: editPlantingsSnackBar

        property int successions: 0

        z: 2
        x: parent.width/2 - width/2
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Modified %L1 planting(s)", "", successions).arg(successions)
        visible: false

        onClicked: {
            Planting.rollback();
            page.refresh();
        }
    }

    Snackbar {
        id: duplicatePlanSnackbar

        property int from: 0
        property int to: 0

        z: 2
        x: parent.width/2 - width/2
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Crop plan of %1 duplicated to %2").arg(from).arg(to)
        visible: false
    }

    Platform.FileDialog {
        id: saveCropPlanDialog

        defaultSuffix: "pdf"
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: {
            var type
            if (printTypeComboBox.currentIndex === 0)
                type  = "entire"
            else if (printTypeComboBox.currentIndex === 1)
                type  = "greenhouse"
            else if (printTypeComboBox.currentIndex === 2)
                type  = "field_sowing"
            else if (printTypeComboBox.currentIndex === 3)
                type  = "field_transplanting"

            var month = -1
            var week = -1
            var rangeIndex = printDateRangeComboBox.currentIndex

            if (rangeIndex === 0)
                week = MDate.currentWeek();
            else if (rangeIndex === 1)
                month = MDate.currentMonth();

            Print.printCropPlan(page.year, month, week, file, type)
        }
    }

    Platform.FileDialog {
        id: importCropPlanDialog
        defaultSuffix: "csv"
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        fileMode: Platform.FileDialog.OpenFile
        nameFilters: [qsTr("CSV (*.csv)")]
        onAccepted: {
            Planting.csvImportPlan(page.year, file);
            page.refresh();
        }
    }

    Platform.FileDialog {
        id: exportCropPlanDialog
        defaultSuffix: "csv"
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: [qsTr("CSV (*.csv)")]
        onAccepted: {
            Planting.csvExportPlan(page.year, file)
        }
    }

    Column {
        id: columnLayout
        anchors.fill: parent

        spacing: 8

        Pane {
            width: parent.width
            padding: 0
            height: parent.height
            Material.elevation: 2
            visible: largeDisplay

            Rectangle {
                id: buttonRectangle
                //            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
                color: checks > 0 ? Material.accent : "white"
                visible: true
                width: parent.width
                height: Units.toolBarHeight
                Material.elevation: 2

                Behavior on color { ColorAnimation { duration: Units.mediumDuration } }

                RowLayout {
                    id: buttonRow
                    anchors.fill: parent
                    visible: !filterMode
                    spacing: Units.smallSpacing

                    FlatButton {
                        id: addButton
                        text: qsTr("Add plantings")
                        visible: checks === 0
                        highlighted: true
                        Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                        onClicked: {
                            plantingDialog.createPlanting()
                        }
                    }

                    ToolButton {
                        id: greenhouseButton
                        checkable: true
                        visible: !checks
                        flat: true
                        text: qsTr("GH", "Abbreviation for \"greenhouse\"")
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Show all plantings")
                                              : qsTr("Show only greenhouse plantings")
                    }

                    IconButton {
                        id: timegraphButton
                        text: "\ue0b8"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true
                        checked: true

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Hide timegraph") : qsTr("Show timegraph")
                    }


                    Button {
                        id: editButton
                        Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                        flat: true
                        text: qsTr("Edit")
                        font.pixelSize: Units.fontSizeBodyAndButton
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: {
                            plantingDialog.editPlantings(selectedIdList());
                        }

                    }

                    Button {
                        id: duplicateButton
                        flat: true
                        text: qsTr("Duplicate")
                        visible: checks > 0
                        Material.foreground: "white"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateSelected()
                    }

                    Button {
                        id: deleteButton
                        flat: true
                        font.pixelSize: Units.fontSizeBodyAndButton
                        text: qsTr("Delete")
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: removeSelected()
                    }

                    Button {
                        id: duplicateNextYear
                        flat: true
                        text: qsTr("Duplicate to next year")
                        visible: checks > 0
                        Material.foreground: "white"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateSelectedNextYear()
                    }

                    Label {
                        visible: deleteButton.visible
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    SearchField {
                        id: filterField
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhPreferLowercase
                        visible: !checks
                    }

                    IconButton {
                        id: taskButton
                        text: "\ue614"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true
                        checked: taskSideSheet.visible

                        onToggled: {
                            if (checked) {
                                if (noteSideSheet.visible)
                                    noteSideSheet.visible = false;
                                if (chartButton.checked)
                                    chartButton.checked = false;
                                taskSideSheet.visible = true
                            } else {
                                taskSideSheet.visible = false
                            }
                        }

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Hide planting's tasks")
                                              : qsTr("Show planting's tasks")
                    }

                    IconButton {
                        id: noteButton

                        text: "\ue24d"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true
                        checked: noteSideSheet.visible

                        onToggled: {
                            if (checked) {
                                if (taskSideSheet.visible)
                                    taskSideSheet.visible = false;
                                if (chartButton.checked)
                                    chartButton.checked = false;
                                noteSideSheet.visible = true;
                            } else {
                                noteSideSheet.visible = false;
                            }
                        }

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.text: checked ? qsTr("Hide notes") : qsTr("Show notes")
                        ToolTip.delay: Units.shortDuration
                    }

                    IconButton {
                        id: chartButton
                        text: "\ue801"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Hide chart")
                                              : qsTr("Show chart")

                        onToggled: {
                            if (!checked)
                                return;
                            if (taskSideSheet.visible)
                                taskSideSheet.visible = false;
                            if (noteSideSheet.visible)
                                noteSideSheet.visible = false;
                        }
                    }

                    Label {
                        text: qsTr("%L1 planting(s) selected", "", checks).arg(checks)
                        color: "white"
                        visible: checks > 0
                        font.family: "Roboto Regular"
                        font.pixelSize: 16
                        Layout.rightMargin: 16
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    SeasonSpinBox {
                        id: seasonSpinBox
                        visible: checks === 0
                        season: MDate.season(todayDate)
                        year: MDate.seasonYear(todayDate)
                    }

                    IconButton {
                        id: menuButton
                        text: "\ue5d4"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        Layout.rightMargin: 16 - padding

                        onClicked: {
                            if (cropMenu.opened) {
                                cropMenu.close();
                            } else {
                                cropMenu.open();
                            }
                        }

                        Menu {
                            id: cropMenu
                            title: qsTr("Crop plan")
                            y: parent.height
                            closePolicy: Popup.CloseOnPressOutsideParent

                            MenuItem {
                                text: qsTr("Export as PDF...")
                                onClicked: printDialog.open();
                            }

                            MenuItem {
                                text: qsTr("Duplicate crop plan...")
                                onClicked: duplicateCropPlanDialog.open();
                            }

                            MenuItem {
                                text: qsTr("Import crop plan...")
                                onClicked: importCropPlanDialog.open()
                            }

                            MenuItem {
                                text: qsTr("Export crop plan...")
                                onClicked: exportCropPlanDialog.open()
                            }
                        }

                        Dialog {
                            id: printDialog
                            title: qsTr("Print crop plan")
                            y: parent.height
                            margins: 0

                            onAccepted: saveCropPlanDialog.open();

                            ColumnLayout {
                                width: parent.width
                                spacing: Units.formSpacing

                                MyComboBox {
                                    id: printTypeComboBox
                                    editable: false
                                    labelText: qsTr("Type")
                                    Layout.fillWidth: true
                                    showAddItem: false
                                    model: [
                                        qsTr("Entire plan"),
                                        qsTr("Greenhouse plan"),
                                        qsTr("Field sowing plan"),
                                        qsTr("Transplanting plan")
                                    ]
                                }

                                MyComboBox {
                                    id: printDateRangeComboBox
                                    editable: false
                                    labelText: qsTr("Date range")
                                    showAddItem: false
                                    model: [
                                        qsTr("Current week"),
                                        qsTr("Current month"),
                                        qsTr("Current year"),
                                    ]
                                    Layout.fillWidth: true
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

                        Dialog {
                            id: duplicateCropPlanDialog
                            title: qsTr("Duplicate crop plan")
                            y: parent.height
                            margins: 0

                            readonly property bool acceptableForm: fromField.acceptableInput && toField.acceptableInput

                            onAboutToShow: {
                                fromField.text = page.year
                                toField.text = page.year + 1
                                fromField.forceActiveFocus()
                            }

                            onAccepted: {
                                Planting.duplicatePlan(Number(fromField.text), Number(toField.text))
                                page.refresh();
                                duplicatePlanSnackbar.from = fromField.text
                                duplicatePlanSnackbar.to = toField.text
                                duplicatePlanSnackbar.open();
                            }

                            footer: AddDialogButtonBox {
                                width: parent.width
                                onAccepted: duplicateCropPlanDialog.accept()
                                onRejected: duplicateCropPlanDialog.reject()
                                acceptableInput: duplicateCropPlanDialog.acceptableForm
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: Units.formSpacing
                                focus: true

                                Keys.onReturnPressed: if (acceptableForm) dialog.accept();
                                Keys.onEnterPressed: if (acceptableForm) dialog.accept();

                                Keys.onEscapePressed: dialog.reject()
                                Keys.onBackPressed: dialog.reject() // especially necessary on Android

                                MyTextField {
                                    id: fromField
                                    width: parent.width
                                    validator: IntValidator { bottom: 2000; top: 3000 }

                                    labelText: qsTr("From")
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 100
                                }

                                MyTextField {
                                    id: toField
                                    width: parent.width
                                    validator: IntValidator { bottom: 2000; top: 3000 }

                                    labelText: qsTr("To")
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 100
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

            BlankLabel {
                id: blankStateColumn
                z: 1
                spacing: Units.smallSpacing
                visible: !page.rowCount
                anchors.centerIn: parent
                primaryText: qsTr('No plantings for this season')
                primaryButtonText: qsTr("Add")

                onPrimaryButtonClicked: plantingDialog.createPlanting()
            }

            PlantingsView {
                id: plantingsView
                year: page.year
                season: page.season
                keywordId: chartPane.keywordId
                showTimegraph: page.showTimegraph
                showOnlyGreenhouse: greenhouseButton.checked
                filterString: page.filterString
                dragActive: false
                anchors {
                    top: topDivider.bottom
                    left: parent.left
                    bottom: chartPane.top
                    right: {
                        if (taskSideSheet.visible)
                           taskSideSheet.left
                        else if (noteSideSheet.visible)
                            noteSideSheet.left
                        else
                            parent.right
                    }
                }
                onDoubleClicked: plantingDialog.editPlantings([plantingId])
            }

            ThinDivider {
                id: middleDivider
                visible: chartPane.visible
                anchors.top: chartPane.top
                width: parent.width
            }

            PlantingsChartPane {
                id: chartPane
                visible: chartButton.checked
                width: parent.width
                height: visible ? parent.height/2 : 0
                year: page.year
                season: page.season
                anchors {
//                    top: topDivider.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }

            PlantingTaskSideSheet {
                id: taskSideSheet
                y: plantingsView.y
                height: plantingsView.height
                anchors {
                    right: parent.right
                    top: topDivider.bottom
                    bottom: parent.bottom
                }
                z: 0
                visible: false
                width: Math.min(Units.desktopSideSheetWidth, window.width*0.3)
                year: MDate.isoYear(todayDate)
                week: MDate.isoWeek(todayDate)
                plantingIdList: selectedIdList()

                Material.elevation: 0
                onTaskDateModified: plantingsView.refresh();
            }

            NoteSideSheet {
                id: noteSideSheet
                anchors {
                    right: parent.right
                    top: topDivider.bottom
                    bottom: parent.bottom
                }
                visible: false
                year: page.year
                y: plantingsView.y
                height: plantingsView.height
                width: visible ? Math.min(Units.desktopSideSheetWidth, window.width*0.3) : 0
                plantingId: page.checks ? page.selectedIdList()[0] : -1
//                onClosed: photoPane.visible = false
                onShowPhoto: {
                    photoPane.photoIdList = Note.photoList(noteId)
                    photoPane.visible = true
                }
                onPlantingIdChanged: console.log("new planting id:", plantingId)
                onHidePhoto: photoPane.visible = false
            }

            PhotoPane {
                id: photoPane
                visible: false
                anchors {
                    top: topDivider.bottom
                    left: parent.left
                    right: noteSideSheet.left
                    bottom: parent.bottom
                }
            }
        }
    }
}
