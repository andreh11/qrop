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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

import io.croplan.components 1.0
import "date.js" as MDate

Page {
    id: page

    property date todayDate: new Date()
    property bool editMode: false
    property alias year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property alias hasSelection: locationView.hasSelection

    function refresh() {
        locationView.refresh();
        plantingsView.refresh()
    }

    title: qsTr("Locations")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)


    onEditModeChanged: {
        if (!editMode) {
            clearSelection();
        }
    }

    Snackbar {
        id: rotationSnackbar
        duration: 1000

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Rotation problem")
        visible: false
    }

    //    Rectangle {
    //        height: 35
    //        width: noteLabel.implicitWidth + Units.smallSpacing * 2
    //        color: "black"
    //        anchors.right: parent.right
    //        anchors.margins: 0

    //        Label {
    //            id: noteLabel
    //            anchors.verticalCenter: parent.verticalCenter
    //            anchors.left: parent.left
    //            anchors.leftMargin: Units.smallSpacing
    //            text: qsTr("Add note")
    //            color: "white"
    //            font.pixelSize: Units.fontSizeBodyAndButton
    //            font.family: "Roboto Regular"
    //            font.capitalization: Font.AllUppercase
    //        }

    //        // Cannot use anchors for the y position, because it will anchor
    //        // to the footer, leaving a large vertical gap.
    //        y: parent.height - height
    //        z: 3
    ////        highlighted: true
    //    }

    Rectangle {
        id: buttonRectangle
        color: page.hasSelection ? Material.accent : "white"
        visible: true
        width: parent.width
        height: 48

        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: buttonRow
            anchors.fill: parent
            spacing: Units.smallSpacing

            Button {
                id: addButton
                Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                text: hasSelection ? qsTr("Add sublocations") : qsTr("Add Locations")
                flat: true
                Material.foreground: page.hasSelection ? "white" : Material.accent
                font.pixelSize: Units.fontSizeBodyAndButton
                visible: editMode
                onClicked: addDialog.open()
                LocationDialog {
                    id: addDialog
                    mode: "add"
                    onAccepted: locationView.addLocations(nameField.text, Number(lengthField.text),
                                             Number(widthField.text), Number(quantityField.text))
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
                    locationIndexes: locationView.selectedIndexes

                    onAccepted: {
                        locationView.updateIndexes(editDialog.editedValues(), locationIndexes);
                        clearSelection();
                    }

                    onRejected: {
                        editDialog.close();
                        clearSelection();
                    }
                }
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
                id: unassignedPlantingsCheckbox
                text: qsTr("Show unassigned plantings")
                Layout.leftMargin: 16
                visible: !editMode
                checked: true
            }

            CheckBox {
                id: emptyLocationsCheckbox
                text: qsTr("Only show empty locations")
                //                visible: !editMode
                visible: false
                checked: false
            }

            SearchField {
                id: searchField
                visible: !editMode
                placeholderText: qsTr("Search Plantings")
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferLowercase
            }
            Item {
                id: fillerItem
                visible: editMode
                Layout.fillWidth: true
            }

            SeasonSpinBox {
                visible: !editMode
                id: seasonSpinBox
                season: MDate.season(todayDate)
                year: todayDate.getFullYear()

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
            margins: Units.smallSpacing
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
            visible: largeDisplay

            LocationView {
                anchors.fill: parent
                id: locationView
                year: seasonSpinBox.year
                season: seasonSpinBox.season
                showOnlyEmptyLocations: emptyLocationsCheckbox.checked
                editMode: page.editMode
                onPlantingRemoved: plantingsView.resetFilter()
            }
        }

        Pane {
            id: plantingsPane
            visible: unassignedPlantingsCheckbox.checked & !editMode
            padding: 0
            Layout.fillWidth: true
            //            Layout.fillHeight: true
            Layout.minimumHeight: page.height / 4
            Material.elevation: 2
            Material.background: "white"

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
                showHeader: false
                showHorizontalScrollBar: false
                showVerticalScrollBar: true
                onDragFinished: locationView.draggedPlantingId = -1
                showOnlyActiveColor: true
                dragActive: true
                tableSortColumn: 3 // planting_date
                tableSortOrder: "ascending"
                filterString: searchField.text
                anchors.fill: parent
            }
        }
    }
}

