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
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.12

import io.croplan.components 1.0
import "date.js" as MDate

Page {
    id: page

    property date todayDate: new Date()
    property bool editMode: false
    property alias year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property alias hasSelection: selectionModel.hasSelection
    property int indentation: 20
    property var colorList: [
        Material.color(Material.Yellow, Material.Shade100),
        Material.color(Material.Green, Material.Shade100),
        Material.color(Material.Blue, Material.Shade100),
        Material.color(Material.Pruple, Material.Shade100),
        Material.color(Material.Teal, Material.Shade100),
        Material.color(Material.Cyan, Material.Shade100)
    ]

    function refresh() {
        locationModel.refresh();
        plantingsView.refresh()
    }

    function clearSelection() {
        // We have to manually refresh selected indexes, because isSelected() isn't properly
        // called after dataChanged().

        // Copy selected indexes.
        var selectedIndexes = [];
        for (var i in selectionModel.selectedIndexes)
            selectedIndexes.push(selectionModel.selectedIndexes[i]);

        selectionModel.clearSelection();

        // Refresh indexes to uncheck checkboxes.
        for (var j in selectedIndexes)
            locationModel.refreshIndex(selectedIndexes[j]);

    }

    function addLocations(name, lenght, width, quantity) {
        if (page.hasSelection)
            locationModel.addLocations(name, lenght, width, quantity, selectionModel.selectedIndexes)
        else
            locationModel.addLocations(name, lenght, width, quantity)
        clearSelection();
    }

    function duplicateSelected() {
        locationModel.duplicateLocations(selectionModel.selectedIndexes)
        clearSelection();
    }

    function removeSelected() {
        var indexList = selectionModel.selectedIndexes.slice()
        locationModel.removeIndexes(indexList)
        plantingsView.resetFilter();
    }

    onEditModeChanged: {
        if (!editMode) {
            clearSelection();
        }
    }

    title: qsTr("Locations")
    focus: true
    padding: 0
    Material.background: Material.color(Material.Grey, Material.Shade100)

    // Declare selection model outside TreeView to avoid odd behavior.
    ItemSelectionModel {
        id: selectionModel
        model: locationModel
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
                    onAccepted: addLocations(nameField.text, Number(lengthField.text),
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
                    locationIndexes: selectionModel.selectedIndexes

                    onAccepted: {
                        locationModel.updateIndexes(editDialog.editedValues(), locationIndexes);
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
                onClicked: duplicateSelected()
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

                    onAccepted: removeSelected()
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

            Rectangle {
                id: headerRectangle
                height: headerRow.height
                implicitWidth: headerRow.width
                color: "white"
                z: 5

                Row {
                    id: headerRow
                    height: Units.rowHeight
                    spacing: Units.smallSpacing
                    leftPadding: 16 + page.indentation

                    CheckBox {
                        id: headerRowCheckBox
                        anchors.verticalCenter: headerRow.verticalCenter
                        visible: page.editMode
                        height: parent.height * 0.8
                        width: height
                        contentItem: Text {}
                        //                            checked: selectionModel.isSelected(styleData.index)
                    }

                    TableHeaderLabel {
                        text: qsTr("Name")
                        width: 120 - (page.editMode ? headerRowCheckBox.width + headerRow.spacing
                                                    : 0)
                    }

                    Row {
                        id: headerTimelineRow
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height

                        Repeater {
                            model: monthsOrder[page.season]
                            Item {
                                width: Units.monthWidth
                                height: parent.height

                                Rectangle {
                                    id: lineRectangle
                                    height: parent.height
                                    width: 1
                                    color: Qt.rgba(0, 0, 0, 0.12)
                                }

                                Label {
                                    text: Qt.locale().monthName(modelData,
                                                                Locale.ShortFormat)
                                    anchors.left: lineRectangle.right
                                    font.family: "Roboto Condensed"
                                    color: Material.color(Material.Grey,
                                                          Material.Shade700)
                                    width: 60 - 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        Rectangle {
                            height: parent.height
                            width: 1
                            color: Qt.rgba(0, 0, 0, 0.12)
                        }
                    }
                }

                ThinDivider {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                }
            }

            // Since we use a Controls 1 TreeWidget, we have to put it in ScrollView + Flickable to
            // have Controls 2 Scrollbars.  When TreeView will be implemented in Controls 2, we'll
            // get rid of this ugly trick...
            ScrollView {
                id: scrollView
                anchors {
                    top: headerRectangle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }



                clip: true

                Flickable {
                    id: flickable

                    boundsBehavior: Flickable.StopAtBounds

                    contentHeight: treeView.flickableItem.contentHeight
                    contentWidth: width

                    ScrollBar.vertical: ScrollBar { id: verticalScrollBar }

                    Controls1.TreeView {
                        id: treeView
                        anchors.fill: parent

                        property int draggedPlantingId: -1
                        property date plantingDate: Planting.plantingDate(draggedPlantingId)
                        property date endHarvestDate: Planting.endHarvestDate(draggedPlantingId)
                        readonly property date seasonBegin: MDate.seasonBeginning(page.season, page.year)

                        frameVisible: false
                        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                        Controls1.TableViewColumn {
                            role: "name"
                        }

                        Rectangle {
                            id: begLine
                            visible: treeView.draggedPlantingId > 0
                            // TODO: remove magic numbers
                            x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2 + Units.position(treeView.seasonBegin, treeView.plantingDate)
                            anchors.top: parent.top
                            anchors.topMargin: Units.rowHeight
                            anchors.bottom: parent.bottom
                            width: 2
                            color: Material.color(Material.Cyan)
                            z: 2
                        }

                        Rectangle {
                            id: endLine
                            visible: treeView.draggedPlantingId > 0
                            // TODO: remove magic numbers
                            x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2 + Units.position(treeView.seasonBegin, treeView.endHarvestDate)
                            anchors.top: parent.top
                            anchors.topMargin: Units.rowHeight
                            anchors.bottom: parent.bottom
                            width: 2
                            color: Material.color(Material.Cyan)
                            z: 2
                        }

//                        backgroundVisible: false
                        headerDelegate: null

                        model: LocationModel {
                            id: locationModel
                            year: seasonSpinBox.year
                            season: seasonSpinBox.season
                            showOnlyEmptyLocations: emptyLocationsCheckbox.checked
                        }


                        style: Styles1.TreeViewStyle {
                            id: treeViewStyle
                            indentation: page.indentation
                            rowDelegate: Rectangle {
                                height: Units.rowHeight + 1
                                color: styleData.hasChildren ? colorList[styleData.depth] : "white"
                                ThinDivider {
                                    anchors {
                                        bottom: parent.bottom
                                        left: parent.left
                                        right: parent.right
                                    }
                                }
                            }

                            branchDelegate:  Rectangle {
                                color: styleData.hasChildren ? colorList[styleData.depth] : "white"
                                width: page.indentation
                                height: Units.rowHeight + 1
                                x: - styleData.depth * page.indentation

                                ThinDivider {
                                    anchors {
                                        bottom: parent.bottom
                                        left: parent.left
                                        right: parent.right
                                    }
                                }
                                Text {
                                    leftPadding: Units.smallSpacing
                                    anchors.centerIn: parent
                                    //                        width: 24
                                    text: styleData.hasChildren ? (styleData.isExpanded ? "\ue313" : "\ue315")
                                                                : ""
                                    font.family: "Material Icons"
                                    font.pixelSize: 22
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        itemDelegate:  Column {
                            property int locationId: locationModel.locationId(styleData.index)
                            Rectangle {
                                width: column.width
                                height: Units.rowHeight + 1
                                color: styleData.hasChildren ? colorList[styleData.depth] : "white"
                                //                        opacity: dropArea.containsDrag ? 1 : 0.8
                                x: - styleData.depth * page.indentation

                                DropArea {
                                    id: dropArea
                                    anchors.fill: parent
                                    onEntered: {
                                        var list = drag.text.split(";")
                                        var plantingId = Number(list[0])
                                        var sourceLocationId = Number(list[1])
                                        if (plantingId !== treeView.draggedPlantingId)
                                            treeView.draggedPlantingId = plantingId;

                                        if (styleData.hasChildren || locationId === sourceLocationId) {
                                            drag.accepted = false
                                        } else {
                                            drag.accepted = locationModel.acceptPlanting(styleData.index,
                                                                                         plantingId)
                                        }
                                    }

                                    onExited: {
                                        treeView.draggedPlantingId = -1;
                                    }

                                    onDropped: {
                                        treeView.draggedPlantingId = -1
                                        if (!styleData.hasChildren
                                                && drop.hasText
                                                && drop.proposedAction == Qt.MoveAction) {

                                            var locationId = locationModel.locationId(styleData.index)
                                            var list = drop.text.split(";")
                                            var plantingId = Number(list[0])
                                            var sourceLocationId = Number(list[1])

//                                            if (!locationModel.rotationRespected(styleData.index, plantingId)) {
//                                                rotationSnackbar.open();
//                                            }

                                            drop.acceptProposedAction()

                                            var length = 0;
                                            if (sourceLocationId > 0) // drag comes from location
                                                length = Location.plantingLength(plantingId, sourceLocationId)
                                            else
                                                length = Planting.lengthToAssign(plantingId)
                                            locationModel.addPlanting(styleData.index, plantingId, length)
                                            locationModel.refreshIndex(styleData.index);
                                        }
                                    }
                                }

                                Column {
                                    id: column

                                    Row {
                                        id: row
                                        height: Units.rowHeight
                                        spacing: Units.smallSpacing
                                        leftPadding: 16

                                        CheckBox {
                                            id: rowCheckBox
                                            anchors.verticalCenter: row.verticalCenter
                                            visible: page.editMode
                                            height: parent.height * 0.8
                                            width: height
                                            contentItem: Text {}
                                            checked: selectionModel.isSelected(styleData.index)
                                            //                                    onClicked: selectionModel.select(styleData.index,
                                            //                                                                     ItemSelectionModel.Toggle)
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (mouse.button !== Qt.LeftButton)
                                                        return

                                                    selectionModel.select(styleData.index,
                                                                          ItemSelectionModel.Toggle)
                                                    // Since selectionModel.isSelected() isn't called after
                                                    // select(), we refresh the index... Ugly but workin'.
                                                    locationModel.refreshIndex(styleData.index)
                                                }
                                            }
                                        }


                                        ToolButton {
                                            id: locationNameLabel
                                            text: hovered ? "\ue889" : styleData.value
                                            font.family: hovered ? "Material Icons" : "Roboto Regular"
                                            font.pixelSize: hovered ? Units.fontSizeTitle : Units.fontSizeBodyAndButton
                                            //                                    showToolTip: true
                                            anchors.verticalCenter: parent.verticalCenter
                                            //                                    elide: Text.ElideRight
                                            //                                    leftPadding: styleData.depth * 20

                                            //                                    MouseArea {
                                            //                                        id: labelMouseArea
                                            //                                        hoverEnabled: true
                                            //                                        anchors.fill: parent
                                            //                                    }

                                            ToolTip.visible: hovered && ToolTip.text
                                            ToolTip.text: {
                                                var text = ""
                                                var plantingIdList = Location.plantings(locationModel.locationId(styleData.index))
                                                var plantingId
                                                for (var i = 0; i < plantingIdList.length; i++) {
                                                    plantingId = plantingIdList[i]
                                                    text += Planting.cropName(plantingId)
                                                            + ", " + Planting.varietyName(plantingId)
                                                            + " " + Planting.plantingDate(plantingId).getFullYear()
                                                            + "\n"
                                                }
                                                return text.slice(0, -1)
                                            }
                                        }


                                        Item {
                                            id: namePadder
                                            height: Units.rowHeight
                                            width: 120 - locationNameLabel.width - row.spacing
                                                   - (rowCheckBox.visible
                                                      ? rowCheckBox.width + row.spacing
                                                      : 0)
                                                   - (rotationAlertLabel.visible
                                                      ? rotationAlertLabel.width + row.spacing
                                                      : 0)

                                        }

                                        ToolButton {
                                            id: rotationAlertLabel
                                            visible: locationModel.hasRotationConflict(styleData.index, season, year)
                                            opacity: visible ? 1 : 0
                                            text: "\ue160"
                                            font.pixelSize: Units.fontSizeTitle
                                            font.family: "Material Icons"
                                            Material.foreground: Material.color(Material.Red)
                                            anchors.verticalCenter: parent.verticalCenter

                                            Behavior on opacity { NumberAnimation { duration: Units.longDuration } }
                                            ToolTip.visible: hovered
                                            ToolTip.text: {
                                                var list = locationModel.conflictingPlantings(styleData.index, season, year)

                                                var text = ""
                                                var plantingId = -1
                                                var locationId = locationModel.locationId(styleData.index)
                                                var conflictList = []
                                                for (var i = 0; i < list.length; i++) {
                                                    plantingId = list[i]

                                                    text += Planting.cropName(plantingId)
                                                            + ", " + Planting.varietyName(plantingId)
                                                    + " " + Planting.plantingDate(plantingId).getFullYear()

                                                    conflictList = Location.conflictingPlantings(locationId, plantingId)
                                                    for (var j = 0; j < conflictList.length; j++) {
                                                        var conflictId = conflictList[j]
                                                        text += " ⋅ " + Planting.cropName(conflictId)
                                                                + ", " + Planting.varietyName(conflictId)
                                                        + " " + Planting.plantingDate(conflictId).getFullYear()
                                                    }
                                                    text += "\n"
                                                }
                                                return text.slice(0, -1)
                                            }

                                        }

                                        Timeline {
                                            height: parent.height
                                            year: seasonSpinBox.year
                                            season: seasonSpinBox.season
                                            showGreenhouseSow: false
                                            showNames: true
                                            showOnlyActiveColor: true
                                            dragActive: true
                                            plantingIdList: locationModel.plantings(styleData.index, season, year)
                                            locationId: locationModel.locationId(styleData.index)
                                            onDragFinished: treeView.draggedPlantingId = -1
                                            onPlantingMoved:  locationModel.refreshIndex(styleData.index)
                                            onPlantingRemoved: {
                                                locationModel.refreshIndex(styleData.index)
                                                plantingsView.resetFilter()
                                            }
                                        }
                                    }
                                }

                                ThinDivider {
                                    anchors {
                                        bottom: parent.bottom
                                        left: parent.left
                                        right: parent.right
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: headerDelegate
                        Rectangle {
                            id: headerRectangle
                            height: headerRow.height
                            implicitWidth: headerRow.width
                            color: "white"
                            z: 5

                            Row {
                                id: headerRow
                                height: Units.rowHeight
                                spacing: Units.smallSpacing
                                leftPadding: 16 + page.indentation

                                CheckBox {
                                    id: headerRowCheckBox
                                    anchors.verticalCenter: headerRow.verticalCenter
                                    visible: page.editMode
                                    height: parent.height * 0.8
                                    width: height
                                    contentItem: Text {}
                                    //                            checked: selectionModel.isSelected(styleData.index)
                                    //                            onClicked: selectionModel.select(styleData.index, ItemSelectionModel.Toggle)
                                }

                                TableHeaderLabel {
                                    text: qsTr("Name")
                                    width: 120 - (page.editMode ? headerRowCheckBox.width + headerRow.spacing
                                                                : 0)
                                }

                                Row {
                                    id: headerTimelineRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: parent.height

                                    Repeater {
                                        model: monthsOrder[page.season]
                                        Item {
                                            width: Units.monthWidth
                                            height: parent.height

                                            Rectangle {
                                                id: lineRectangle
                                                height: parent.height
                                                width: 1
                                                color: Qt.rgba(0, 0, 0, 0.12)
                                            }

                                            Label {
                                                text: Qt.locale().monthName(modelData,
                                                                            Locale.ShortFormat)
                                                anchors.left: lineRectangle.right
                                                font.family: "Roboto Condensed"
                                                color: Material.color(Material.Grey,
                                                                      Material.Shade700)
                                                width: 60 - 1
                                                anchors.verticalCenter: parent.verticalCenter
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        height: parent.height
                                        width: 1
                                        color: Qt.rgba(0, 0, 0, 0.12)
                                    }
                                }
                            }

                            ThinDivider {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            }
                        }
                    }
                }
            }
        }

        Pane {
            id: plantingsPane
            visible: unassignedPlantingsCheckbox.checked & !editMode
            padding: 0
            Layout.fillWidth: true
            //            Layout.fillHeight: true
            Layout.minimumHeight: 300
            Material.elevation: 2
            Material.background: "white"

            DropArea {
                id: plantingsDropArea
                anchors.fill: parent
                onEntered: {
                    drag.accepted = true
                    treeView.draggedPlantingId = -1;
                }

                onDropped: {
                    if (drop.hasText && (drop.proposedAction === Qt.MoveAction
                                         || drop.proposedAction === Qt.CopyAction)) {
                        drop.acceptProposedAction()
                        treeView.draggedPlantingId = -1;
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
                onDragFinished: treeView.draggedPlantingId = -1
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

