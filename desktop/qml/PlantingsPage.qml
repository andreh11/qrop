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

    title: qsTr("Plantings")
    padding: 0
    Material.background: "white"

    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property bool shortcutEnabled: navigationIndex === 0 && !dialogOpened
    property alias filterString: filterField.text
    property alias year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property date todayDate: new Date()
    property alias searchField: filterField

    property bool showOnlyGreenhouse: filterField.filterIndex === 1
    property bool showOnlyField: filterField.filterIndex === 2
    property alias showFinished: showFinishButton.checked

    property alias model: plantingsView.model
    property alias rowCount: plantingsView.rowCount
    property alias selectedIds: plantingsView.selectedIds
    property alias checks: plantingsView.checks
    property alias dialogOpened: plantingDialog.opened

    property var printTypeCbModel: [ // needed for Qt < 5.14
        {text: qsTr("Entire plan"),        value: "entire" },
        {text: qsTr("Greenhouse plan"),    value: "greenhouse" },
        {text: qsTr("Field sowing plan"),  value: "field_sowing" },
        {text: qsTr("Transplanting plan"), value: "field_transplanting" }
    ]
    property var dateRangeCbModel: [ // needed for Qt < 5.14
        { text: qsTr("Current week"),  value : PlantingsPage.DateFilter.Week },
        { text: qsTr("Current month"), value : PlantingsPage.DateFilter.Month },
        { text: qsTr("Current year"),  value : PlantingsPage.DateFilter.Year }
    ]


    signal noteButtonClicked(int plantingId)

    property bool exportCSV: true

    function refresh() {
        plantingsView.refresh();
        taskSideSheet.refresh();
        chartPane.refresh();
    }

    function selectedIdList() {
        let idList = [];
        for (let key in selectedIds) {
            if (selectedIds[key])
                idList.push(key);
        }
        return idList;
    }

    function duplicateSelected() {
        let idList = selectedIdList();
        Planting.duplicateList(idList);
        plantingsView.unselectAll();
        page.refresh();
        plantingsView.selectedIdsChanged();
    }

    function duplicateSelectedNextYear() {
        let idList = selectedIdList();
        Planting.duplicateListToNextYear(idList);
        plantingsView.unselectAll();
        page.refresh();
        plantingsView.selectedIdsChanged();
    }

    function removeSelected() {
        let ids = []
        for (let key in selectedIds) {
            if (selectedIds[key]) {
                selectedIds[key] = false;
                ids.push(key);
            }
        }
        Planting.removeList(ids)
        page.refresh()
        plantingsView.selectedIdsChanged()
    }

    function doPrintCropPlan(file) {
        console.log("FILE", file)
        let printType  = printTypeCbModel[printTypeComboBox.currentIndex].value;
        let dateFilter = dateRangeCbModel[printDateRangeComboBox.currentIndex].value;
        // Can be used from Qt 5.14
        //        let printType  = printTypeComboBox.currentValue;
        //        let dateFilter = printDateRangeComboBox.currentValue;
        let month = dateFilter == PlantingsPage.DateFilter.Month  ? QrpDate.currentMonth() : -1 ;
        let week  = dateFilter == PlantingsPage.DateFilter.Week ? QrpDate.currentWeek() : -1 ;
        console.log("dateFilter", dateFilter, "printType", printType, "MONTH", month, "WEEK", week)
        Print.printCropPlan(page.year, month, week, file, printType)
    }

    function openActionCsvDialog(doExport) {
        exportCSV = doExport;
        if (BuildInfo.isMobileDevice()) {
            if (exportCSV) {
                csvCropPlanMobileDialog.nameField.visible = true;
                csvCropPlanMobileDialog.combo.visible = false;
                csvCropPlanMobileDialog.title = qsTr('Export Crop Plan');
                csvCropPlanMobileDialog.text = qsTr("Please type a name for the CSV.");
                csvCropPlanMobileDialog.open();
            } else {
                let availableCSVs = FileSystem.getAvailableCsvFileNames();
                if (availableCSVs.length === 0) {
                    error(qsTr('There are no CSV file to import...'),
                          '%1: <b>%2</b>'.arg(
                              qsTr("They should be in the following folder")).arg(
                              FileSystem.csvPath));
                } else {
                    for (var i=0; i < availableCSVs.length; ++i)
                        print("[MB_TRACE] Available csv: "+availableCSVs[i]);
                    csvCropPlanMobileDialog.nameField.visible = false;
                    csvCropPlanMobileDialog.combo.visible = true;
                    csvCropPlanMobileDialog.combo.model = availableCSVs;
                    csvCropPlanMobileDialog.title = qsTr('Import Crop Plan');
                    csvCropPlanMobileDialog.text = '%1<br/>%2 %3'.arg(
                                qsTr("Please select a csv to import")).arg(
                                qsTr("They must be in the folder:")).arg(
                                FileSystem.csvPath);
                    csvCropPlanMobileDialog.open();
                }

            }
        } else {
            csvCropPlanDialog.open();
        }
    }

    function doActionCSV(file) {
        if (exportCSV) {
            let err = Planting.csvExportPlan(page.year, file);
            if (err.length > 0)
                window.error(qsTr('Error exporting crop plan: %s'.arg(err)));
            else
                window.info(qsTr('Export done.'));
        } else {
            let err = Planting.csvImportPlan(page.year, file);
            if (err.length > 0)
                window.error(qsTr('Error importing crop plan: %s'.arg(err)))
            else {
                page.refresh();
                window.info(qsTr('Import done.'));
            }
        }
    } // doActionCSV

    Column {
        id: columnLayout
        anchors.fill: parent

        spacing: 8

        Pane {
            width: parent.width
            padding: 0
            height: parent.height
            Material.elevation: 2

            Rectangle {
                id: buttonRectangle
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
                    } // addButton

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
                    } // timegraphButton

                    IconButton {
                        id: showFinishButton
                        text: "\ue876"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true
                        checked: false

                        Layout.leftMargin: -padding
                        Layout.rightMargin: Layout.leftMargin

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Hide finished plantings") : qsTr("Show finished plantings")
                    } // showFinishButton

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
                    } // editButton

                    Button {
                        id: duplicateButton
                        flat: true
                        text: qsTr("Duplicate")
                        visible: checks > 0
                        Material.foreground: "white"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateSelected()
                    } // duplicateButton

                    Button {
                        id: deleteButton
                        flat: true
                        font.pixelSize: Units.fontSizeBodyAndButton
                        text: qsTr("Delete")
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: removeSelected()
                    } // deleteButton

                    Button {
                        id: finishiButton
                        flat: true
                        font.pixelSize: Units.fontSizeBodyAndButton
                        text: qsTr("Finish")
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: finishDialog.open()
                    } // finishiButton

                    Button {
                        id: duplicateNextYear
                        flat: true
                        text: qsTr("Duplicate to next year")
                        visible: checks > 0
                        Material.foreground: "white"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateSelectedNextYear()
                    } // duplicateNextYear

                    Label {
                        visible: deleteButton.visible
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    SearchField {
                        id: filterField
                        placeholderText: qsTr("Search Plantings")
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhPreferLowercase
                        visible: !checks
                        filterModel: [qsTr("All"), qsTr("Greenhouse"), qsTr("Field")]
                    } // filterField

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
                    } // taskButton

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
                    } // noteButton

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
                    } // chartButton

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
                        season: QrpDate.season(todayDate)
                        year: QrpDate.seasonYear(todayDate)
                    } // seasonSpinBox

                    //                    TitleLabel {
                    //                        title: "Revenue"
                    //                        text: qsTr("%L1 €").arg(plantingsView.revenue)
                    //                    }

                    IconButton {
                        id: menuButton
                        text: "\ue5d4"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        Layout.rightMargin: 16 - padding
                        onClicked: cropMenu.open();
                    } // menuButton
                } // buttonRow
            } // buttonRectangle

            ThinDivider {
                id: topDivider
                anchors.top: buttonRectangle.bottom
                width: parent.width
            } // topDivider

            BlankLabel {
                id: blankStateColumn
                z: 1
                spacing: Units.smallSpacing
                visible: !page.rowCount
                anchors.centerIn: parent
                primaryText: qsTr('No plantings for this season')
                primaryButtonText: qsTr("Add")

                onPrimaryButtonClicked: plantingDialog.createPlanting()
            } // blankStateColumn

            PlantingsView {
                id: plantingsView
                year: page.year
                season: page.season
                keywordId: chartPane.keywordId
                showTimegraph: page.showTimegraph
                showOnlyGreenhouse: page.showOnlyGreenhouse
                showOnlyField: page.showOnlyField
                showFinished: page.showFinished
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
            } // plantingsView

            ThinDivider {
                id: middleDivider
                visible: chartPane.visible
                anchors.top: chartPane.top
                width: parent.width
            } // middleDivider

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
            } // chartPane

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
                year: QrpDate.isoYear(todayDate)
                week: QrpDate.isoWeek(todayDate)
                plantingIdList: selectedIdList()

                Material.elevation: 0
                onTaskDateModified: plantingsView.refresh();
            } // taskSideSheet

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
            } // noteSideSheet

            PhotoPane {
                id: photoPane
                visible: false
                anchors {
                    top: topDivider.bottom
                    left: parent.left
                    right: noteSideSheet.left
                    bottom: parent.bottom
                }
            } // photoPane
        } // Pane
    } // columnLayout

    // Dialogs

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
    } // plantingDialog

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
    } // addPlantingSnackbar

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
    } // editPlantingsSnackBar

    Snackbar {
        id: duplicatePlanSnackbar

        property int from: 0
        property int to: 0

        z: 2
        x: parent.width/2 - width/2
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Crop plan of %1 duplicated to %2").arg(from).arg(to)
        visible: false
    } // duplicatePlanSnackbar

    Platform.FileDialog {
        id: printCropPlanDialog

        defaultSuffix: "pdf"
        fileMode: Platform.FileDialog.SaveFile
        folder: Qt.resolvedUrl(window.lastFolder)
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: doPrintCropPlan(file)
    } // printCropPlanDialog

    MobileFileDialog {
        id: printCropPlanMobileDialog

        x: page.width - width
        y: buttonRectangle.height

        nameField.visible : true;
        combo.visible : false;
        title : qsTr("Print crop plan");
        text : qsTr("Please type a name for the PDF.");

        onAccepted: {
            doPrintCropPlan('file://%1/%2.csv'.arg(FileSystem.pdfPath).arg(nameField.text));
        }
    } // printCropPlanMobileDialog

    Platform.FileDialog {
        id: csvCropPlanDialog

        defaultSuffix: "csv"
        folder: Qt.resolvedUrl(window.lastFolder)
        fileMode: exportCSV ? Platform.FileDialog.SaveFile : Platform.FileDialog.OpenFile
        nameFilters: [qsTr("CSV (*.csv)")]
        onAccepted: {
            print("export? "+exportCSV+", fileMode: " + fileMode);
            doActionCSV(file);
        }
    } // csvCropPlanDialog

    MobileFileDialog {
        id: csvCropPlanMobileDialog

        x: page.width - width
        y: buttonRectangle.height

        onAccepted: {
            //MB_TODO: check if the file already exist? shall we overwrite or discard?
            let csvName = exportCSV ? nameField.text : combo.currentText;
            doActionCSV('file://%1/%2.csv'.arg(FileSystem.csvPath).arg(csvName));
        }
    } // csvCropPlanMobileDialog


    Dialog {
        id: finishDialog
        title: qsTr("Finish plantings")

        x: finishiButton.x
        y: buttonRectangle.height

        onAccepted: {
            Planting.finish(page.selectedIdList(), lvFinishReason.currentIndex + 1);
            plantingsView.unselectAll();
            page.refresh();
        }

        ColumnLayout {
            Label {
                text: qsTr("Why are you finishing these plantings?")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
            }

            ListView {
                id: lvFinishReason

                onCurrentIndexChanged: console.log(currentIndex)

                width: parent.width
                height: childrenRect.height
                implicitHeight: childrenRect.height
                boundsBehavior: Flickable.StopAtBounds
                model: [
                    qsTr("Finished harvest "),
                    qsTr("Crop failure"),
                    qsTr("Never seeded"),
                    qsTr("Never transplanted")
                ]

                delegate: RadioDelegate {
                    text: modelData
                    onCheckedChanged: {
                        if (checked)
                            lvFinishReason.currentIndex = index
                    }
                }

            }
        }

        footer: DialogButtonBox {
            Button {
                flat: true
                text: qsTr("Cancel")
                Material.foreground: Material.accent
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            }

            Button {
                Material.background: Material.accent
                Material.foreground: "white"
                text: qsTr("Finish")

                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            }
        }
    } // finishDialog

    Menu {
        id: cropMenu
        title: qsTr("Crop plan")

        x: page.width - width
        y: 0

        MenuItem {
            text: qsTr("Export as PDF...")
            onTriggered: printDialog.open();
        }

        MenuItem {
            text: qsTr("Duplicate crop plan...")
            onTriggered: duplicateCropPlanDialog.open();
        }

        MenuItem {
            text: qsTr("Import crop plan...")
            onTriggered: openActionCsvDialog(false)
        }

        MenuItem {
            text: qsTr("Export crop plan...")
            onTriggered: openActionCsvDialog(true)
        }
    } // cropMenu

    enum DateFilter {
        Week = 0,
        Month,
        Year
    }

    Dialog {
        id: printDialog
        title: qsTr("Print crop plan")
        x: page.width - width
        y: buttonRectangle.height

        onAccepted: {
            if (BuildInfo.isMobileDevice())
                printCropPlanMobileDialog.open();
            else
                printCropPlanDialog.open();
        }

        ColumnLayout {
            width: parent.width
            spacing: Units.formSpacing

            MyComboBox {
                id: printTypeComboBox
                labelText: qsTr("Type")
                editable: false
                Layout.fillWidth: true
                showAddItem: false
                textRole: "text"
                model: printTypeCbModel
                // Can be used from Qt 5.14
                //                model: [
                //                    {text: qsTr("Entire plan"),        value: "entire" },
                //                    {text: qsTr("Greenhouse plan"),    value: "greenhouse" },
                //                    {text: qsTr("Field sowing plan"),  value: "field_sowing" },
                //                    {text: qsTr("Transplanting plan"), value: "field_transplanting" }
                //                ]
                //                valueRole: "value"

            }

            MyComboBox {
                id: printDateRangeComboBox
                labelText: qsTr("Date range")
                editable: false
                Layout.fillWidth: true
                showAddItem: false
                textRole: "text"
                model: dateRangeCbModel
                // Can be used from Qt 5.14
                //                model: [
                //                    {text: qsTr("Current week"),  value : PlantingsPage.DateFilter.Week},
                //                    {text: qsTr("Current month"), value : PlantingsPage.DateFilter.Month},
                //                    {text: qsTr("Current year"),  value : PlantingsPage.DateFilter.Year},
                //                ]
                //                valueRole: "value"
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
    } // printDialog


    Dialog {
        id: duplicateCropPlanDialog
        title: qsTr("Duplicate crop plan")
        x: page.width - width
        y: buttonRectangle.height
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
    } // duplicateCropPlanDialog

    // Shortcuts

    ApplicationShortcut {
        sequences: ["Ctrl+N"]
        enabled: shortcutEnabled && addButton.visible
        onActivated: addButton.clicked()
    }

    ApplicationShortcut {
        sequences: ["Ctrl+T"]
        enabled: shortcutEnabled && addButton.visible
        onActivated: timegraphButton.toggle()
    }

    ApplicationShortcut {
        sequences: [StandardKey.Find]
        enabled: shortcutEnabled && filterField.visible
        onActivated: filterField.forceActiveFocus();
    }

    ApplicationShortcut {
        sequence: "Ctrl+E"
        enabled: shortcutEnabled && editButton.visible
        onActivated: editButton.clicked()
    }

    ApplicationShortcut {
        sequence: "Ctrl+D"
        enabled: shortcutEnabled && duplicateButton.visible
        onActivated: duplicateButton.clicked()
    }

    ApplicationShortcut {
        sequence: StandardKey.Delete
        enabled: shortcutEnabled && deleteButton.visible
        onActivated: deleteButton.clicked()
    }

    ApplicationShortcut {
        sequence: StandardKey.SelectAll
        enabled: shortcutEnabled && !deleteButton.visible
        onActivated: plantingsView.selectAll();
    }

    ApplicationShortcut {
        sequence: StandardKey.Deselect
        enabled: shortcutEnabled && deleteButton.visible
        onActivated: plantingsView.unselectAll()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Right"
        enabled: shortcutEnabled && !deleteButton.visible
        onActivated: seasonSpinBox.nextSeason()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Left"
        enabled: shortcutEnabled && !deleteButton.visible
        onActivated: seasonSpinBox.previousSeason();
    }

    ApplicationShortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: shortcutEnabled && !plantingsView.activeFocus
        onActivated: {
            plantingsView.currentIndex = 0
            plantingsView.forceActiveFocus();
        }
    }

    ApplicationShortcut {
        sequence: "Ctrl+Up"
        enabled: shortcutEnabled && !deleteButton.visible
        onActivated: seasonSpinBox.nextYear()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Down"
        enabled: shortcutEnabled && !deleteButton.visible
        onActivated: seasonSpinBox.previousYear();
    }
}
