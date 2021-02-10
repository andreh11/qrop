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
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Page {
    id: page

    property date todayDate: new Date()
    property alias editMode: editCropMapButton.checked
    property alias year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property alias hasSelection: locationView.hasSelection
    property alias rowCount: locationView.rowCount
    property bool showPlantingsPane: true
    property bool showOnlyGreenhouse: filterField.filterIndex === 1
    property bool showOnlyField: filterField.filterIndex === 2
    property bool shortcutEnabled: navigationIndex === 2 && filterField.visible
                                   && !addDialog.activeFocus && !editDialog.activeFocus

    function refresh() {
        locationView.refresh();
        plantingsView.refresh();
    }

    function reload() {
        locationView.reload();
    }

    function previousSeason() {
        seasonSpinBox.previousSeason();
    }

    function nextSeason() {
        seasonSpinBox.nextSeason();
    }

    function doPrint(file) {
        Print.printCropMap(page.year, page.season, file, familyColorButton.checked,
                                                page.showOnlyGreenhouse)
    }

    title: qsTr("Locations")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)



    onEditModeChanged: {
        if (!editMode) {
            locationView.clearSelection();
        }
    }



    RoundButton {
        id: editCropMapButton
        z: 2
        // Cannot use anchors for the y position, because it will anchor
        // to the footer, leaving a large vertical gap.
        y: parent.height - height - anchors.margins
        checkable: true
        width: 56
        height: width
        anchors.right: parent.right
        anchors.margins: 12
        text: editMode ? "\ue0b8" : "\ue254"
        font.family: "Material Icons"
        font.pixelSize: 20
        highlighted: true
        rotation: editMode ? 0 : 360
        //        ToolTip.visible: hovered

        ToolTip {
            y: -parent.width/2
            visible: parent.hovered
            text: editMode ? qsTr("Assign locations") : qsTr("Edit Crop Map")
        }

        Behavior on rotation { NumberAnimation { duration: 200 } }
    }

    Rectangle {
        id: buttonRectangle
        color: page.hasSelection ? Material.accent : "white"
        visible: true
        width: parent.width
        height: Units.toolBarHeight

        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: buttonRow
            anchors.fill: parent
            spacing: Units.smallSpacing

            FlatButton {
                id: addButton
                Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                text: hasSelection ? qsTr("Add sublocations") : qsTr("Add Locations")
                highlighted: true
                visible: editMode
                onClicked: addDialog.open()
                LocationDialog {
                    id: addDialog
                    mode: "add"
                    onApplied: locationView.addLocations(name, bedLength, bedWidth, quantity, greenhouse)
                    onAccepted: locationView.addLocations(name, bedLength, bedWidth, quantity, greenhouse)
                    onRejected: addDialog.close()
                }
            }

            Button {
                id: editLocationButton
                Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                flat: true
                text: qsTr("Edit")
                font.pixelSize: Units.fontSizeBodyAndButton
                visible: editMode && hasSelection
                Material.foreground: "white"
                onClicked: editDialog.open()

                LocationDialog {
                    id: editDialog
                    mode: "edit"
                    locationIdList: locationView.selectedIdList

                    onAccepted: {
                        locationView.updateSelected(editDialog.editedValues());
                        locationView.clearSelection();
                    }

                    onRejected: {
                        editDialog.close();
                        locationView.clearSelection();
                    }
                }
            }

            RoundButton {
                id: expandButton
                visible: !editMode
                flat: true
                text: "\ue313"
                font.family: "Material Icons"
                font.pixelSize: 24
                onClicked: expandMenu.open();

                property int depth: locationView.treeDepth
                property var expandBoolList: ({})

                function expandLevel(level) {
                    if (expandBoolList[level]) {
                        locationView.collapseAll(level, false)
                    } else {
                        locationView.expandAll(level)
                        for (var i = 0; i < level; i++) {
                            expandBoolList[i] = true
                        }
                    }
                    expandBoolList[level] = !expandBoolList[level]
                    expandBoolListChanged();
                }

                Component.onCompleted: {
                    for (var i; i < depth; i++)
                        expandBoolList[i+1] = false
                }

                ToolTip.text: qsTr("Expand and collapse location levels")
                ToolTip.delay: Units.shortDuration
                ToolTip.visible: hovered

                Menu {
                    id: expandMenu
                    y: expandButton.height

                    Repeater {
                        model: expandButton.depth
                        MenuItem {
                            text: index + 1
                            checkable: true
                            checked: expandButton.expandBoolList[index]
                                     ? expandButton.expandBoolList[index]
                                     : false
                            onTriggered: expandButton.expandLevel(index)
                        }
                    }
                }
            }

            RoundButton {
                id: familyColorButton
                visible: !editMode
                checkable: true
                flat: true
                text: checked ? qsTr("F", "Abbreviation for family") : qsTr("C", "Abbreviation for crop")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                ToolTip.text: checked ? qsTr("Click to show crop color") : qsTr("Click to show family color")
                ToolTip.visible: hovered
            }


            Button {
                id: duplicateButton
                flat: true
                text: qsTr("Duplicate")
                visible: editMode && hasSelection
                Material.foreground: "white"
                font.pixelSize: Units.fontSizeBodyAndButton
                onClicked: locationView.duplicateSelected()
            }

            Button {
                id: deleteButton
                flat: true
                font.pixelSize: Units.fontSizeBodyAndButton
                text: qsTr("Delete")
                visible: editMode && hasSelection
                Material.foreground: "white"
                onClicked: deleteDialog.open()

                Dialog {
                    id: deleteDialog

                    title: qsTr("Remove selected locations?")
                    standardButtons: Dialog.Ok | Dialog.Cancel

                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("This will remove the selected locations and their sublocations. The whole planting history will be lost!")
                    }

                    onAccepted: locationView.removeSelected()
                    onRejected: dialog.close()
                }
            }

            CheckBox {
                id: emptyLocationsCheckbox
                text: qsTr("Only show empty locations")
                //                visible: !editMode
                visible: false
                checked: false
            }

            SearchField {
                id: filterField
                visible: !editMode
                placeholderText: qsTr("Search Plantings")
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferLowercase
                filterModel: [
                    qsTr("All"),
                    qsTr("Greenhouse"),
                    qsTr("Field"),
                ]
            }

            Item {
                id: fillerItem
                visible: editMode
                Layout.fillWidth: true
            }

            SeasonSpinBox {
                id: seasonSpinBox
                visible: !editMode
                season: QrpDate.season(todayDate)
                year: QrpDate.seasonYear(todayDate)
            }

            IconButton {
                id: printButton
                text: "\ue8ad"
                hoverEnabled: true
                visible: !editMode

                Layout.rightMargin: 16 - padding
                ToolTip.visible: hovered
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.text: qsTr("Print the crop map")

                onClicked: {
                    if (cppQrop.isMobileDevice())
                        saveCropMapMobileDialog.open();
                    else
                        saveCropMapDialog.open();
                }
            }
        }
    }

    ThinDivider {
        id: topDivider
        anchors.top: buttonRectangle.bottom
        width: parent.width
    }

    ColumnLayout {
        Layout.fillHeight: true
        anchors {
            top: topDivider.bottom
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 0
        }
        spacing: Units.smallSpacing
        width: plantingsView.implicitWidth
        clip: true

        Pane {
            id: locationPane
            padding: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.elevation: 2
            Material.background: "white"

            BlankLabel {
                id: emptyStateColumn
                z: 3
                visible: !page.rowCount
                anchors.centerIn: parent
                primaryText: page.showOnlyGreenhouse ? qsTr("No greenhouse locations yet") : qsTr('No locations yet')
                primaryButtonText: qsTr("Add")

                onPrimaryButtonClicked: {
                    editCropMapButton.checked = true;
                    addDialog.open();
                }
            }

            LocationView {
                id: locationView
                anchors.fill: parent
                year: seasonSpinBox.year
                season: seasonSpinBox.season
                showOnlyGreenhouseLocations: page.showOnlyGreenhouse
                showFamilyColor: familyColorButton.checked
                editMode: page.editMode
                firstColumnWidth: plantingsView.firstColumnWidth
                onPlantingRemoved: plantingsView.resetFilter()
            }
        }

        Pane {
            id: plantingsPane
            visible: !editMode

            padding: 0
            Layout.fillWidth: true
            Layout.minimumHeight: showPlantingsPane ? page.height / 4 : 0
            Material.elevation: 2
            Material.background: "white"

            Behavior on Layout.minimumHeight {
                NumberAnimation { duration: Units.shortDuration  }
            }

            MouseArea {
                id: plantingPaneMouseArea
                anchors.fill: parent
                hoverEnabled: true

                RoundButton {
                    id: showPlantingPaneButton
                    z: -1
                    Material.background: "white"
                    width: 60
                    height: width
                    anchors.top: parent.top
                    anchors.topMargin: visible ? -width/2 : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: showPlantingsPane =!showPlantingsPane
                    contentItem: Text {
                        text: showPlantingsPane ? "\ue313" : "\ue316"
                        font.family: "Material Icons"
                        font.pixelSize: 24
                        //                    color: parent.down ? "#17a81a" : "#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.Top
                        elide: Text.ElideRight
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: showPlantingsPane ? qsTr("Hide the plantings pane") : qsTr("Show the planting pane")
                    ToolTip.delay: Units.shortDuration

                    Behavior on anchors.topMargin {
                        NumberAnimation { duration: Units.shortDuration  }
                    }
                }

                Rectangle {
                    color: "white"
                    anchors.fill: parent
                }

                BlankLabel {
                    id: emptyPlantingStateColumn
                    visible: !plantingsView.rowCount && showPlantingsPane
                    z:2
                    anchors.centerIn: parent
                    spacing: Units.smallSpacing
                    primaryText: {
                        if (filterField.text && page.showOnlyGreenhouse)
                            qsTr('No more greenhouse plantings of “%1” to assign for this season.').arg(filterField.text)
                        else if (filterField.text)
                            qsTr('No more plantings of “%1” to assign for this season.').arg(filterField.text)
                        else if (page.showOnlyGreenhouse)
                            qsTr('No more greenhouse plantings to assign for this season.')
                        else
                            qsTr('No more plantings to assign for this season.')
                    }
                    primaryButtonText: filterField.text ? qsTr("Clear search Field") : ""
                    highlightPrimaryButton: false
                    onPrimaryButtonClicked: filterField.text = ""
                }

                DropArea {
                    id: plantingsDropArea
                    anchors.fill: parent
                    onEntered: {
                        drag.accepted = true
                        locationView.draggedPlantingId = -1;
                    }

                    onDropped: {
                        if (drop.hasText && (drop.proposedAction === Qt.MoveAction
                                             || drop.proposedAction === Qt.CopyAction)) {
                            drop.acceptProposedAction()
                            locationView.draggedPlantingId = -1;
                        }
                    }
                }

                PlantingsView {
                    id: plantingsView
                    year: page.year
                    season: page.season
                    showOnlyUnassigned: true
                    showTimegraph: true
                    showOnlyTimegraph: true
                    showOnlyGreenhouse: page.showOnlyGreenhouse
                    showOnlyField: page.showOnlyField
                    showHeader: false
                    showHorizontalScrollBar: false
                    showVerticalScrollBar: true
                    onDragFinished: locationView.draggedPlantingId = -1
                    showOnlyActiveColor: true
                    showFamilyColor: familyColorButton.checked
                    dragActive: true
                    tableSortColumn: 4 // planting_date
                    tableSortOrder: "ascending"
                    filterString: filterField.text
                    anchors.fill: parent
                }
            }
        }
    }

    // Dialogs

    Snackbar {
        id: rotationSnackbar
        duration: 1000

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Rotation problem")
        visible: false
    }

    Platform.FileDialog {
        id: saveCropMapDialog

        defaultSuffix: "pdf"
        folder: Qt.resolvedUrl(window.lastFolder)
        fileMode: Platform.FileDialog.SaveFile
        nameFilters: [qsTr("PDF (*.pdf)")]
        onAccepted: doPrint(file)
    }

    MobileFileDialog {
        id: saveCropMapMobileDialog

        title : qsTr("Print the crop map")
        text : qsTr("Please type a name for the PDF.")
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
        sequences: [StandardKey.Find]; enabled: shortcutEnabled; onActivated: filterField.forceActiveFocus();
    }

    ApplicationShortcut {
        sequence: "Ctrl+P"; enabled: shortcutEnabled; onActivated: showPlantingPaneButton.clicked()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Right"; enabled: shortcutEnabled; onActivated: seasonSpinBox.nextSeason()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Left"; enabled: shortcutEnabled; onActivated: seasonSpinBox.previousSeason();
    }

    ApplicationShortcut {
        sequence: "Ctrl+Up"; enabled: shortcutEnabled; onActivated: seasonSpinBox.nextYear()
    }

    ApplicationShortcut {
        sequence: "Ctrl+Down"; enabled: shortcutEnabled; onActivated: seasonSpinBox.previousYear();
    }

    ApplicationShortcut {
        sequence: "Shift+A"; enabled: shortcutEnabled; onActivated: expandButton.expandLevel(0)
    }

    ApplicationShortcut {
        sequence: "Shift+B"; enabled: shortcutEnabled; onActivated: expandButton.expandLevel(1)
    }

    ApplicationShortcut {
        sequence: "Shift+C"; enabled: shortcutEnabled; onActivated: expandButton.expandLevel(2)
    }

    ApplicationShortcut {
        sequence: "Shift+D"; enabled: shortcutEnabled; onActivated: expandButton.expandLevel(3)
    }

    ApplicationShortcut {
        sequence: "Shift+E"; enabled: shortcutEnabled; onActivated: expandButton.expandLevel(4)
    }
}
