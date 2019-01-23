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
import QtQml.Models 2.10

import io.croplan.components 1.0
import "date.js" as MDate

// Since we use a Controls 1 TreeWidget, we have to put it in ScrollView + Flickable to
// have Controls 2 Scrollbars.  When TreeView will be implemented in Controls 2, we'll
// get rid of this ugly trick...

Item {
    id: locationView

    property alias year: locationModel.year
    property alias season: locationModel.season
    property alias rowCount: locationModel.rowCount
    property alias showOnlyEmptyLocations: locationModel.showOnlyEmptyLocations
    property alias hasSelection: selectionModel.hasSelection
    property alias selectedIndexes: selectionModel.selectedIndexes
    property alias draggedPlantingId: treeView.draggedPlantingId

    property LocationModel locationModel
    property alias treeDepth: locationModel.depth
    property int treeViewHeight: treeView.flickableItem.contentHeight
    property int treeViewWidth: treeView.implicitWidth
    property bool alwaysShowCheckbox: false
    property bool editMode: false
    property bool showTimeline: true
    property bool showHeader: true
    property int indentation: 20
    property var colorList: [
        Material.color(Material.Yellow, Material.Shade100),
        Material.color(Material.Green, Material.Shade100),
        Material.color(Material.Blue, Material.Shade100),
        Material.color(Material.Pruple, Material.Shade100),
        Material.color(Material.Teal, Material.Shade100),
        Material.color(Material.Cyan, Material.Shade100)
    ]

    property bool plantingEditMode: false
    property date editedPlantingPlantingDate
    property date editedPlantingEndHarvestDate
    property int editedPlantingLength
    property var assignedLengthMap: ({})
    property var assignedIdMap: selectedLocationIdMap()
    property int remainingLength: editedPlantingLength - assignedLength()

    signal plantingMoved()
    signal plantingRemoved()
    signal addPlantingLength(int length)

    function refresh() {
        locationModel.refresh();
    }

    function updateIndexes(map, indexes) {
        locationModel.updateIndexes(map, indexes);
    }

    // TODO: improve performance
    function selectAll() {
        // Select all indexes
        selectionModel.select(locationModel.treeSelection(), ItemSelectionModel.Select)
        // Update view indexes
        var indexList = locationModel.treeIndexes();
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            locationModel.refreshIndex(index);
        }
    }

    function deselectAll() {
        selectionModel.clear();
        //        selectionModel.select(locationModel.treeSelection(), ItemSelectionModel.Deselect)
        var indexList = locationModel.treeIndexes();
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            locationModel.refreshIndex(index);
        }
    }

    function expandAll(depth) {
        var indexList = locationModel.treeIndexes(depth);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            treeView.expand(index);
        }
    }

    function collapseAll(depth) {
        var indexList = locationModel.treeIndexes(depth, false);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            treeView.collapse(index);
        }
    }

    function clearSelection() {
        // We have to manually refresh selected indexes, because isSelected() isn't properly
        // called after dataChanged().

        // Copy selected indexes.
        var selectedIndexes = [];
        for (var i in selectionModel.selectedIndexes) {
            var idx = selectionModel.selectedIndexes[i];
            selectedIndexes.push(idx);
        }

        selectionModel.clearSelection();
        assignedLengthMap = ({})

        // Refresh indexes to uncheck checkboxes.
        for (var j in selectedIndexes)
            locationModel.refreshIndex(selectedIndexes[j]);

    }

    function selectLocationIds(idList) {
        var indexList = locationModel.treeHasIds(idList);
        for (var i = 0; i < indexList.length; i++) {
            var idx = indexList[i]
            var parent = locationModel.parent(idx)
            selectionModel.select(idx, ItemSelectionModel.Select);
            treeView.expand(parent)
        }
    }

    function selectedLocationIds() {
        var list = [];
        var selectedIndexes = selectionModel.selectedIndexes;

        for (var i = 0; i < selectedIndexes.length; i++) {
            list.push(locationModel.locationId(selectedIndexes[i]));
        }
        return list;
    }

    function selectedLocationIdMap() {
        var map = ({});

        for (var i = 0; i < selectedIndexes.length; i++) {
            var index = selectedIndexes[i]
            var locationId = locationModel.locationId(index)
            var length = assignedLengthMap[index]
            map[locationId] = length
        }
        return map;
    }

    function assignedLength() {
        var length = 0
        for (var index in assignedLengthMap) {
            length += assignedLengthMap[index];
        }
        return length;
    }

    function addLocations(name, lenght, width, quantity) {
        if (locationView.hasSelection)
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

    LocationModel {
        id: locationModel
    }

    // Declare selection model outside TreeView to avoid odd behavior.
    ItemSelectionModel {
        id: selectionModel
        model: locationModel
    }

    Rectangle {
        id: headerRectangle
        visible: showHeader
        height: showHeader ? headerRow.height : 0
        implicitWidth: headerRow.width
        color: "white"
        z: 5

        Row {
            id: headerRow
            height: Units.rowHeight
            spacing: Units.smallSpacing
            leftPadding: 16 + locationView.indentation

            CheckBox {
                id: headerRowCheckBox
                anchors.verticalCenter: headerRow.verticalCenter
                visible: locationView.editMode
                height: parent.height * 0.8
                width: height
                contentItem: Text {}

                tristate: true

                checkState: rowCount && locationModel.treeIndexes().length === selectionModel.selectedIndexes.length
                            ? Qt.Checked
                            : (selectionModel.selectedIndexes.length > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                nextCheckState: function () {
                    if (!rowCount)
                        return;

                    if (checkState == Qt.Checked) {
                        console.log("unselect")
                        locationView.deselectAll()
                        return Qt.Unchecked
                    } else {
                        console.log("select")
                        locationView.selectAll()
                        return Qt.Checked
                    }
                }
            }

            TableHeaderLabel {
                text: qsTr("Name")
                width: 120 - (locationView.editMode ? headerRowCheckBox.width + headerRow.spacing
                                                    : 0)
            }

            Row {
                id: headerTimelineRow
                visible: locationView.showTimeline
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height

                Repeater {
                    model: monthsOrder[locationView.season]
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

        ThinDivider { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

//    ScrollView {
//        id: scrollView
//        anchors {
//            top: headerRectangle.bottom
//            left: parent.left
//            right: parent.right
//            bottom: parent.bottom
//        }

//        clip: true

//        Flickable {
//            id: flickable

//            boundsBehavior: Flickable.StopAtBounds
//            contentHeight: treeView.flickableItem.contentHeight
//            contentWidth: width

//            ScrollBar.vertical: ScrollBar { id: verticalScrollBar }

            Controls1.TreeView {
                id: treeView
//                anchors.fill: parent
                anchors {
                    top: headerRectangle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                property int draggedPlantingId: -1
                property date plantingDate: Planting.plantingDate(draggedPlantingId)
                property date endHarvestDate: Planting.endHarvestDate(draggedPlantingId)
                readonly property date seasonBegin: MDate.seasonBeginning(locationView.season,
                                                                          locationView.year)

                property var expandIndex: null
                property var draggedOnIndex: null
                property alias expandTimer: expandTimer

                Timer {
                    id: expandTimer
                    interval: 300
                    onTriggered: {
                        if (treeView.expandIndex && treeView.expandIndex === treeView.draggedOnIndex) {
                            treeView.expand(treeView.expandIndex);
                            treeView.draggedOnIndex = null;
                        }
                    }
                }

                frameVisible: false
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
                implicitWidth: headerRectangle.implicitWidth + 80

                Controls1.TableViewColumn {
                    role: "name"
                }

                Rectangle {
                    id: begLine
                    visible: plantingEditMode ||  treeView.draggedPlantingId > 0
                    // TODO: remove magic numbers
                    x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2
                       + Units.position(treeView.seasonBegin, plantingEditMode ? editedPlantingPlantingDate
                                                                               : treeView.plantingDate)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2
                    color: Material.color(Material.Green)
                    z: 2
                }

                Rectangle {
                    id: endLine
                    visible: plantingEditMode || treeView.draggedPlantingId > 0
                    // TODO: remove magic numbers
                    x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2
                       + Units.position(treeView.seasonBegin, plantingEditMode ? editedPlantingEndHarvestDate
                                                                               : treeView.endHarvestDate)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2
                    color: Material.color(Material.Green)
                    z: 2
                }

                backgroundVisible: false
                headerDelegate: null
                model: locationModel

                style: Styles1.TreeViewStyle {
                    id: treeViewStyle
                    indentation: locationView.indentation
                    rowDelegate: Rectangle {
                        height: Units.rowHeight + 1
                        color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                                         selectionModel.isSelected(styleData.index) ? 1.1 :  1)

                        ThinDivider {
                            anchors {
                                bottom: parent.bottom
                                left: parent.left
                                right: parent.right
                            }
                        }
                    }

                    branchDelegate:  Rectangle {
                        id: branchRectangle
                        color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                                         selectionModel.isSelected(styleData.index) ? 1.1 :  1)
                        width: locationView.indentation
                        height: Units.rowHeight + 1
                        x: - styleData.depth * locationView.indentation

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
                            text: styleData.hasChildren
                                  ? (styleData.isExpanded ? "\ue313" : "\ue315")
                                  : ""
                            font { family: "Material Icons"; pixelSize: 22 }
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                itemDelegate:  Column {
                    property int locationId: locationModel.locationId(styleData.index)
                    Rectangle {
                        width: parent.width
                        height: Units.rowHeight + 1
                        color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                                         selectionModel.isSelected(styleData.index) ? 1.1 :  1)

                        //                        opacity: dropArea.containsDrag ? 1 : 0.8
                        x: - styleData.depth * locationView.indentation

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
                                    if (!styleData.isExpanded) {
                                        treeView.expandIndex = styleData.index
                                        treeView.draggedOnIndex = styleData.index
                                        treeView.expandTimer.stop();
                                        treeView.expandTimer.start();
                                    }
                                    drag.accepted = false;
                                } else {
                                    drag.accepted = locationModel.acceptPlanting(styleData.index,
                                                                                 plantingId)
                                }
                            }

                            onExited: {
                                treeView.draggedPlantingId = -1;
                                treeView.draggedOnIndex = null
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

                                    //                                    if (!locationModel.rotationRespected(styleData.index, plantingId)) {
                                    //                                        rotationSnackbar.open();
                                    //                                    }

                                    drop.acceptProposedAction()

                                    var length = 0;
                                    if (sourceLocationId > 0) // drag comes from location
                                        length = Location.plantingLength(plantingId, sourceLocationId)
                                    else
                                        length = Planting.lengthToAssign(plantingId)
                                    locationModel.addPlanting(styleData.index, plantingId, length)
                                    locationModel.refreshIndex(styleData.index);
                                    treeView.draggedOnIndex = null
                                    treeView.expandIndex = null
                                }
                            }
                        }

                        MouseArea {
                            id: rowMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (styleData.hasChildren || !locationView.plantingEditMode)
                                    return;
                                if (!locationModel.acceptPlanting(styleData.index,
                                                                  editedPlantingPlantingDate,
                                                                  editedPlantingEndHarvestDate))
                                    return;

                                if (selectionModel.isSelected(styleData.index)) {
                                    assignedLengthMap[styleData.index] = 0
                                } else {
                                    if (remainingLength === 0) {
                                        assignedLengthMap[styleData.index] =
                                                locationModel.availableSpace(styleData.index,
                                                                             editedPlantingPlantingDate,
                                                                             editedPlantingEndHarvestDate);
                                        locationView.addPlantingLength(assignedLengthMap[styleData.index]);
                                    } else {
                                        assignedLengthMap[styleData.index] =
                                                Math.min(remainingLength,
                                                         locationModel.availableSpace(styleData.index,
                                                                                      editedPlantingPlantingDate,
                                                                                      editedPlantingEndHarvestDate));
                                    }
                                }

                                selectionModel.select(styleData.index, ItemSelectionModel.Toggle)
                                assignedLengthMapChanged()
                                locationModel.refreshIndex(styleData.index);
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
                                        visible: locationView.editMode || locationView.alwaysShowCheckbox
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
                                        visible: locationView.showTimeline
                                        year: locationView.year
                                        season: locationView.season
                                        showGreenhouseSow: false
                                        showNames: true
                                        showOnlyActiveColor: true
                                        dragActive: true
                                        plantingIdList: locationModel.plantings(styleData.index, season, year)
                                        locationId: locationModel.locationId(styleData.index)
                                        onDragFinished: treeView.draggedPlantingId = -1
                                        onPlantingMoved: {
                                            locationModel.refreshIndex(styleData.index)
                                            locationView.plantingMoved()
                                        }
                                        onPlantingRemoved: {
                                            locationModel.refreshIndex(styleData.index)
                                            locationView.plantingRemoved()
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
            }
        }
//    }
//}
