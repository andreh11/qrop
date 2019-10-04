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
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: root

    property LocationModel model: locationModel
    property alias currentIndex: listView.currentIndex
    property var __model: TreeModelAdaptor {
        id: modelAdaptor
        model: root.model
    }

    property alias year: locationModel.year
    property alias season: locationModel.season

    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    readonly property date seasonEnd: MDate.seasonEnd(season, year)
    property date todayDate: new Date()
    property int firstColumnWidth
    property int editedPlantingId: -1

    property alias rowCount: locationModel.rowCount
    //    property alias showOnlyEmptyLocations: locationModel.showOnlyEmptyLocations
    property alias showOnlyGreenhouseLocations: locationModel.showOnlyGreenhouseLocations
    property alias selectedIndexes: selectionModel.selectedIndexes
    property var selectedIdList: selectedLocationIds()
    property bool hasSelection: selectedIdList.length > 0
//    property alias draggedPlantingId: locationView.draggedPlantingId
    property bool showFamilyColor: false

//    property int treeViewHeight: listView.contentHeight
    property int treeViewHeight: listView.contentItem.height
    property int treeViewWidth: implicitWidth
    onTreeViewWidthChanged: console.log("treeview width", treeViewWidth)

    property int treeDepth: locationModel ? locationModel.depth : 0

    property int locationViewHeight: root.childrenRect.height
    property int locationViewWidth: root.implicitWidth
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

    property int draggedPlantingId: -1
    property date plantingDate: Planting.plantingDate(draggedPlantingId)
    property date endHarvestDate: Planting.endHarvestDate(draggedPlantingId)

    property var expandIndex: -1
    property var draggedOnIndex: -1
    property alias expandTimer: expandTimer

    signal plantingMoved
    signal plantingRemoved
    signal addPlantingLength(real length)

    function refresh() {
        locationModel.refreshTree();
    }

    function reload() {
        locationModel.refresh();
    }

    function contains(array, elt) {
        return array.indexOf(elt) > -1
    }

    function mapRowToModelIndex(row) {
        return modelAdaptor.mapRowToModelIndex(row);
    }

    function plantings(row) {
        return locationModel.plantings(mapRowToModelIndex(row));
    }

    function setAssignedLength(row, length) {
        assignedLengthMap[mapRowToModelIndex(row)] = length;
    }

    function assignedLengthRow(row) {
        return assignedLengthMap[mapRowToModelIndex(row)];
    }

    function availableSpace(row, plantingDate, endHarvestDate)
    {
        return locationModel.availableSpace(mapRowToModelIndex(row), plantingDate, endHarvestDate);
    }

    function refreshRow(row) {
        locationModel.refreshIndex(mapRowToModelIndex(row));
    }

    function selectRow(row) {
        selectionModel.select(mapRowToModelIndex(row), ItemSelectionModel.Toggle)
    }

    function expandRow(row) {
        modelAdaptor.expandRow(row);
    }

    function acceptDraggedPlanting(row) {
        return locationModel.acceptPlanting(mapRowToModelIndex(row), plantingDate, endHarvestDate);
    }

    function acceptPlantingDate(row, plantingDate, endHarvestDate) {
        return locationModel.acceptPlanting(mapRowToModelIndex(row), plantingDate, endHarvestDate);
    }

    function addPlanting(row, plantingId, length, addToSiblings) {
        locationModel.addPlanting(mapRowToModelIndex(row), plantingId, length, addToSiblings);
    }

    function isSelected(row) {
        // We cannot use selectionModel.isSelected(). We have to bind to
        // selectexIndexes, otherwise this property won't but updated when
        // several checkboxes are toggled at the same time.
        return contains(selectionModel.selectedIndexes, mapRowToModelIndex(row))
    }

    function selectAll() {
        selectionModel.select(locationModel.treeSelection(), ItemSelectionModel.Select);
        locationModel.refreshTree();
    }

    function selectSubTree(row) {
        const index = mapRowToModelIndex(row);
        selectionModel.select(locationModel.treeSelection(index), ItemSelectionModel.Toggle);
        locationModel.refreshTree(index);
      }

    function deselectAll() {
        selectionModel.clear();
        locationModel.refreshTree();
    }

    function clearSelection() {
        deselectAll();
        assignedLengthMap = ({})
    }

    //! Expand all nodes of given depth (and their parents).
    function expandAll(depth) {
        var indexList = locationModel.treeIndexes(depth);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            modelAdaptor.expand(index);
        }
    }

    //! Expand all nodes from root to index's parent.
    function expandPath(index) {
        var path = locationModel.treePath(index);
        for (var i = 0; i < path.length; i++) {
            if (!modelAdaptor.isExpanded(path[i]))
                modelAdaptor.expand(path[i]);
        }
    }

    //! Collapse all nodes of given depth (and their parents).
    function collapseAll(depth) {
        var indexList = locationModel.treeIndexes(depth, false);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            modelAdaptor.collapse(index);
        }
    }

    function selectLocationIds(idList) {
        const indexList = locationModel.treeHasIds(idList);

        for (var i = 0; i < indexList.length; i++) {
            const idx = indexList[i];
            selectionModel.select(idx, ItemSelectionModel.Select);
            expandPath(idx);

            if (editedPlantingId > 0)
                assignedLengthMap[idx] = locationModel.plantingLength(editedPlantingId, idx);
        }
        assignedLengthMapChanged();
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

    function addLocations(name, length, width, quantity, greenhouse) {
        if (root.hasSelection)
            locationModel.addLocations(name, length, width, quantity, greenhouse, selectionModel.selectedIndexes);
        else
            locationModel.addLocations(name, length, width, quantity, greenhouse);
        clearSelection();
    }

    function updateIndexes(map, indexes) {
        locationModel.updateIndexes(map, indexes);
    }

    function updateSelected(map) {
        updateIndexes(map, selectionModel.selectedIndexes);
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

    ItemSelectionModel {
        id: selectionModel
        model: locationModel
    }

    Settings {
        id: locationSettings
        category: "LocationView"
        property bool showFullName
        property bool allowPlantingsConflict
        property bool showTasks
    }

    ListView {
        id: listView

        clip: true
        cacheBuffer: Units.rowHeight * 20
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent

        ScrollBar.vertical: ScrollBar { }

        model: root.__model

        headerPositioning: ListView.OverlayHeader
        header: Rectangle {
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
                leftPadding: 16

//                Row {
//                    id: firstColumnRow
//                    height: parent.height
//                    width: firstColumnWidth - 16 - spacing
//                    spacing: headerRow.spacing
//                    anchors.verticalCenter: parent.verticalCenter

                    CheckBox {
                        id: headerRowCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.editMode
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
                                root.deselectAll();
                                return Qt.Unchecked;
                            } else {
                                root.selectAll()
                                return Qt.Checked;
                            }
                        }
                    }

                    TableHeaderLabel {
                        id: nameTableLabel
                        text: qsTr("Name")
                        condensed: true
                        width: firstColumnWidth - headerRow.spacing - headerRow.leftPadding
                               - (root.editMode ? headerRow.spacing + headerRowCheckBox.width : 0)
                    }

                HeaderTimelineRow {
                    id: headerTimelineRow
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.showTimeline
                    season: root.season
                }
            }

            ThinDivider { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
        }

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlight: Rectangle {
            visible: root.activeFocus
            z:3;
            opacity: 0.1;
            color: Material.primary
            radius: 2
        }

        delegate: Rectangle {
            id: locationDelegate

            property int currentRow: index
            property int currentLocationId: model.location_id
            property var plantingRowList: model.nonOverlappingPlantingList
            property var taskRowList: model.taskList
            property int rows: plantingRowList.length
            property bool hasLocationTasks: taskRowList.length > plantingRowList.length
            property bool isSelected: root.isSelected(currentRow)


            clip: true
            width: ListView.view.width // fill available width
            height: Math.max(1,rows) * Units.rowHeight + 1

            color: Qt.darker(model.hasChildren ? colorList[model.depth] : "white",
                             (isSelected) ? 1.1 : 1)

            Behavior on height {
                NumberAnimation {
                    duration: Units.shortDuration
                }
            }

            DropArea {
                id: dropArea
                anchors.fill: parent

                onEntered: {
                    const list = drag.text.split(";")
                    const plantingId = Number(list[0])
                    const sourceLocationId = Number(list[1])
                    if (plantingId !== root.draggedPlantingId)
                        root.draggedPlantingId = plantingId;

                    if (model.hasChildren) {
                        if (!model.expanded) {
                            root.expandIndex = currentRow
                            root.draggedOnIndex = currentRow
                            root.expandTimer.stop();
                            root.expandTimer.start();
                        }
                        drag.accepted = (model.depth >= locationModel.depth - 1);
                    } else if (currentLocationId !== sourceLocationId) {
                        drag.accepted = locationSettings.allowPlantingsConflict
                                || root.acceptDraggedPlanting(currentRow);
                    } else {
                        drag.accepted = false;
                    }

                }

                onExited: {
                    root.draggedPlantingId = -1;
                    root.draggedOnIndex = null
                }

                onDropped: {
                    root.draggedPlantingId = -1

                    if (drop.hasText && (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction)) {
                        const locationId = model.location_id;
                        const list = drop.text.split(";");
                        const plantingId = Number(list[0]);
                        const sourceLocationId = Number(list[1]);

                        drop.acceptProposedAction();

                        let length = 0;
                        if (sourceLocationId > 0) // drag comes from location
                            length = Location.plantingLength(plantingId, sourceLocationId);
                        else // drag comes from planting view
                            length = Planting.lengthToAssign(plantingId);

                        root.addPlanting(currentRow, plantingId, length, drop.proposedAction === Qt.CopyAction)

                        root.draggedOnIndex = null;
                        root.expandIndex = null;
                    }
                }
            }

            MouseArea {
                id: rowMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (model.hasChildren || !root.plantingEditMode)
                        return;

                    var plantings = root.plantings(currentRow);
                    if (!locationSettings.allowPlantingsConflict
                            && !isSelected
                            && !root.acceptPlantingDate(currentRow,
                                                    editedPlantingPlantingDate,
                                                    editedPlantingEndHarvestDate)
                            && !plantings.includes(editedPlantingId)) {
                        return;
                    }

                    if (isSelected) {
                        root.setAssignedLength(currentRow, 0);
                    } else if (plantings.includes(editedPlantingId)) {
                        root.setAssignedLength(currentRow,
                                       Location.plantingLength(editedPlantingId, model.location_id));
                    } else {
                        var space = root.availableSpace(currentRow,
                                                        editedPlantingPlantingDate,
                                                        editedPlantingEndHarvestDate)
                        if (remainingLength === 0) {
                            root.setAssignedLength(currentRow, space);
                            root.addPlantingLength(root.assignedLengthRow(currentRow));
                        } else {
                           console.log(2) ;
                            setAssignedLength(currentRow, Math.min(remainingLength, space));
                        }
                    }

                    selectRow(currentRow)
                    assignedLengthMapChanged()
                    refreshRow(currentRow)
                }
            }

            RowLayout {
                id: layout
                spacing: 0
                anchors.fill: parent
                anchors.leftMargin: 0

                Row  {
                    Layout.minimumWidth: firstColumnWidth
                    Layout.maximumWidth: firstColumnWidth
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft

                    AbstractButton {
                        id: arrowControl
                        height: parent.height
                        width: 18
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: model.expanded = !model.expanded

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: model.hasChildren ? (model.expanded ? "\ue313" : "\ue315") : ""
                            font { family: "Material Icons"; pixelSize: 22 }
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }

                    CheckBox {
                        id: rowCheckBox
                        visible: root.editMode || root.alwaysShowCheckbox
                        height: parent.height * 0.8
                        width: height
                        contentItem: Item {}
                        checked: isSelected
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (mouse.button !== Qt.LeftButton)
                                    return;

                                if (mouse.modifiers & Qt.ControlModifier)
                                    selectSubTree(currentRow);
                                root.selectRow(currentRow);
                            }
                        }
                    }

                    ToolButton {
                        id: locationNameLabel
                        text: hovered ? "\ue889" :
                                        (locationSettings.showFullName ? Location.fullName(model.location_id) : model.name)
                        font.family: hovered ? "Material Icons" : "Roboto Regular"
                        font.pixelSize: hovered ? Units.fontSizeTitle : Units.fontSizeBodyAndButton
                        hoverEnabled: !model.hasChildren

                        ToolTip.visible: hovered && ToolTip.text
                        ToolTip.text: model.history
                    }

//                    ConflictAlertButton {
//                        id: conflictAlertButton
//                        visible: false
//                        //                    anchors.verticalCenter: parent.verticalCenter
//                        //                    conflictList: model.hidden ? [] : Location.spaceConflictingPlantings(model.location_id, seasonBegin, seasonEnd)
//                        conflictList: []
//                        year: root.year
//                        locationId: model.location_id

//                        onPlantingModified: {
//                            refreshRow(currentRow);
//                            timeline.refresh();
//                        }
//                        onPlantingRemoved: {
//                            root.plantingRemoved();
//                            refreshRow(currentRow);
//                            timeline.refresh();
//                        }
//                    }

                    ToolButton {
                        id: rotationAlertLabel
                        visible: model.rotationConflictList.length > 0
                        opacity: visible ? 1 : 0
                        text: "\ue160"
                        font.pixelSize: Units.fontSizeTitle
                        font.family: "Material Icons"
                        Material.foreground: Material.color(Material.Red)
                        //                    anchors.verticalCenter: parent.verticalCenter

                        Behavior on opacity { NumberAnimation { duration: Units.longDuration } }
                        ToolTip.visible: hovered && ToolTip.text
                        ToolTip.text: ""

                        //                        onHoveredChanged: {
                        //                            if (hovered && !ToolTip.text)
                        //                                ToolTip.text = locationModel.rotationConflictingDescription(styleData.index, season, year)
                        //                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    MonthGrid {
                        visible: !locationDelegate.plantingRowList.length
                        height: parent.height
                        width: parent.width
                    }

                    TaskTimeline {
                        id: locationTaskTimeline
                        visible: locationDelegate.hasLocationTasks
                        model: visible ? locationDelegate.taskRowList[taskRowList.length - 1] : []
                        seasonBegin: root.seasonBegin
                        season: root.season
                        year: root.year
                        height: locationDelegate.height
                        width: parent.width
                    }

                    Column {
                        id: timelineColumn
                        Repeater {
                            model: locationDelegate.plantingRowList

                            Timeline {
                                id: timeline
                                height: Units.rowHeight
                                visible: root.showTimeline
                                year: root.year
                                season: root.season
                                showGreenhouseSow: false
                                showNames: true
                                showTasks: locationSettings.showTasks
                                showOnlyActiveColor: true
                                showFamilyColor: root.showFamilyColor
                                dragActive: true
                                plantingIdList: modelData
                                taskIdList: locationDelegate.taskRowList[index]
                                locationId: currentLocationId
                                onDragFinished: root.draggedPlantingId = -1
                                onPlantingMoved: refreshRow(currentRow)
                                onPlantingRemoved: refreshRow(currentRow)
                                Component.onCompleted: {
                                    plantingMoved.connect(root.plantingMoved)
                                    plantingRemoved.connect(root.plantingRemoved)
                                }
                            }
                        }
                    }
                }

            }

            ThinDivider {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            }
        }

        Rectangle {
            id: plantingBeginningLine
            x: firstColumnWidth
               + Units.position(root.seasonBegin, plantingEditMode ? editedPlantingPlantingDate
                                                                   : root.plantingDate)
            visible: plantingEditMode || root.draggedPlantingId > 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: Material.color(Material.Green)
        }

        Rectangle {
            id: plantingEndLine
            width: 2
            x: firstColumnWidth
               + Units.position(root.seasonBegin, plantingEditMode ? editedPlantingEndHarvestDate
                                                                           : root.endHarvestDate)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            visible: plantingEditMode || root.draggedPlantingId > 0
            color: Material.color(Material.Green)
        }

        Rectangle {
            id: todayLine
            property int _pos: Units.position(seasonBegin, todayDate)
            x: firstColumnWidth + _pos
            z: 1
            visible: (_pos > 0) && (_pos < Units.timegraphWidth)
            width: 1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: Material.accent
        }

        Timer {
            id: expandTimer
            interval: 300
            onTriggered: {
                if ((root.expandIndex > 0)
                        && (root.expandIndex === root.draggedOnIndex)) {
                    expandRow(root.expandIndex);
                    root.draggedOnIndex = -1;
                }
            }
        }
    }
}
