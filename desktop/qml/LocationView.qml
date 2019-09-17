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
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

ListView {
    id: locationView

    property int year
    property int season

    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    readonly property date seasonEnd: MDate.seasonEnd(season, year)
    property date todayDate: new Date()
    property int firstColumnWidth
    property int editedPlantingId: -1

    property int rowCount: locationTreeViewModel.rowCount
    //    property alias showOnlyEmptyLocations: locationModel.showOnlyEmptyLocations
    property alias showOnlyGreenhouseLocations: locationTreeViewModel.showOnlyGreenhouseLocations
    property alias hasSelection: selectionModel.hasSelection
    property alias selectedIndexes: selectionModel.selectedIndexes
    property alias draggedPlantingId: locationView.draggedPlantingId
    property bool showFamilyColor: false

    property alias treeDepth: locationTreeViewModel.depth
    property int headerHeight: headerRow.height
    //    property int locationViewHeight: locationView.flickableItem.contentHeight
    property int locationViewHeight: locationView.contentHeight
    property int locationViewWidth: locationView.implicitWidth
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

    ScrollBar.vertical: ScrollBar { }

    signal plantingMoved
    signal plantingRemoved
    signal addPlantingLength(int length)

    function refresh() {
        locationTreeViewModel.refreshTree();
    }

    function reload() {
        locationTreeViewModel.refresh();
    }

    function updateIndexes(map, indexes) {
        locationTreeViewModel.updateIndexes(map, indexes);
    }

    // TODO: optimize
    function selectAll() {
        console.time("selectAll")
        selectionModel.select(locationTreeViewModel.treeSelection(), ItemSelectionModel.Select);
        //        console.log(l);
        //        for (var i = 0; i < l.length; i++) {
        //            selectionModel.select(l[i], ItemSelectionModel.Select)
        ////        }
        locationTreeViewModel.refreshTree();
        console.timeEnd("selectAll")
    }

    function selectSubTree(index) {
        locationTreeViewModel.toggleIsTreeSelected(index, true)
        //        selectionModel.select(locationTreeViewModel.treeSelection(index), ItemSelectionModel.Toggle);
        //        locationTreeViewModel.refreshTree(index);
    }

    function deselectAll() {
        selectionModel.clear();
        locationTreeViewModel.refreshTree();
    }

    function expandAll(depth) {
        var indexList = locationTreeViewModel.treeIndexes(depth);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            locationView.expand(index);
        }
    }

    function collapseAll(depth) {
        var indexList = locationTreeViewModel.treeIndexes(depth, false);
        for (var i = 0; i < indexList.length; i++) {
            var index = indexList[i];
            locationView.collapse(index);
        }
    }

    function clearSelection() {
        editedPlantingId = -1;

        // We have to manually refresh selected indexes, because isSelected() isn't properly
        // called after dataChanged(). Is ItemSelectionModel buggy regarding signals?

        // Copy selected indexes.
        var selectedIndexes = [];
        for (var i in selectionModel.selectedIndexes) {
            var idx = selectionModel.selectedIndexes[i];
            selectedIndexes.push(idx);
        }

        selectionModel.clearSelection();
        // It seems that selectionModel.clearSelection() doesn't emit selectedIndexesChanged().
        // We have to do it manually.
        selectedIndexesChanged();
        assignedLengthMap = ({})

        // Refresh the unselected indexes to uncheck checkboxes.
        for (var j in selectedIndexes)
            locationTreeViewModel.refreshIndex(selectedIndexes[j]);
    }

    function selectLocationIds(idList) {
        var indexList = locationTreeViewModel.treeHasIds(idList);

        for (var i = 0; i < indexList.length; i++) {
            var idx = indexList[i];
            selectionModel.select(idx, ItemSelectionModel.Select);
            expandPath(idx);

            if (editedPlantingId > 0)
                assignedLengthMap[idx] = locationTreeViewModel.plantingLength(editedPlantingId, idx);
        }
        assignedLengthMapChanged();
    }

    //! Expand all nodes from root to index's parent.
    function expandPath(index) {
        var path = locationTreeViewModel.treePath(index);
        for (var i = 0; i < path.length; i++) {
            if (!locationView.isExpanded(path[i]))
                locationView.expand(path[i]);
        }
    }

    function selectedLocationIds() {
        var list = [];
        var selectedIndexes = selectionModel.selectedIndexes;
        for (var i = 0; i < selectedIndexes.length; i++) {
            list.push(locationTreeViewModel.locationId(selectedIndexes[i]));
        }
        return list;
    }

    function selectedLocationIdMap() {
        var map = ({});
        for (var i = 0; i < selectedIndexes.length; i++) {
            var index = selectedIndexes[i]
            var locationId = locationTreeViewModel.locationId(index)
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

    function addLocations(name, length, width, quantity) {
        if (locationView.hasSelection)
            locationTreeViewModel.addLocations(name, length, width, quantity, selectionModel.selectedIndexes)
        else
            locationTreeViewModel.addLocations(name, length, width, quantity)
        clearSelection();
    }

    function duplicateSelected() {
        locationTreeViewModel.duplicateLocations(selectionModel.selectedIndexes)
        clearSelection();
    }

    function removeSelected() {
        var indexList = selectionModel.selectedIndexes.slice()
        locationTreeViewModel.removeIndexes(indexList)
        plantingsView.resetFilter();
    }


    Settings {
        id: locationSettings
        category: "LocationView"
        property bool showFullName
        property bool allowPlantingsConflict
        property bool showTasks
    }

    LocationTreeViewModel {
        id: locationTreeViewModel
    }

    // Declare selection model outside TreeView to avoid odd behavior.
    ItemSelectionModel {
        id: selectionModel
        model: locationTreeViewModel
    }

    Rectangle {
        id: todayLine
        x: firstColumnWidth + Units.position(seasonBegin, todayDate)
        z: 1
        visible: x !== 0 && x !== Units.graphWidth
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.accent
    }

    clip: true
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

            Row {
                id: firstColumnRow
                height: parent.height
                width: firstColumnWidth - 16 - spacing
                spacing: headerRow.spacing

                CheckBox {
                    id: headerRowCheckBox
                    anchors.verticalCenter: headerRow.verticalCenter
                    visible: locationView.editMode
                    height: parent.height * 0.8
                    width: height
                    contentItem: Text {}

                    tristate: true

                    checkState: rowCount && locationTreeViewModel.treeIndexes().length === selectionModel.selectedIndexes.length
                                ? Qt.Checked
                                : (selectionModel.selectedIndexes.length > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                    nextCheckState: function () {
                        if (!rowCount)
                            return;

                        if (checkState == Qt.Checked) {
                            locationView.deselectAll();
                            return Qt.Unchecked;
                        } else {
                            locationView.selectAll()
                            return Qt.Checked;
                        }
                    }
                }

                TableHeaderLabel {
                    id: nameTableLabel
                    text: qsTr("Name")
                    condensed: true
                }
            }

            HeaderTimelineRow {
                id: headerTimelineRow
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                visible: locationView.showTimeline
                season: locationView.season
            }
        }

        ThinDivider { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } }
    }

    model: locationTreeViewModel

    delegate: Rectangle {
        id: locationDelegate

        property int currentIndex: index
        property int currentLocationId: model.location_id
        property var plantingRowList: [[]]
        property int rows: plantingRowList.length

        function toggleIsExpanded() {
            if (model.hasChildren)
                model.isExpanded = !model.isExpanded
        }

        Binding on plantingRowList {
            when: !model.hidden
            value: Location.nonOverlappingPlantingList(model.location_id, seasonBegin, seasonEnd)
        }

        clip: true
        // collapsed items have a null height
        visible: !model.hidden
        // fill available width
        width: ListView.view.width
        height: {
            if (model.hidden)
                return 0;
            if (model.hasChildren) {
                return Units.rowHeight + 1;
            } else {
                return Math.max(1,rows) * Units.rowHeight + 1
            }
        }
        color: Qt.darker(model.hasChildren ? colorList[model.indentation] : "white",
                         model.isSelected ? 1.1 : 1)

        DropArea {
            id: dropArea
            anchors.fill: parent

            onEntered: {
                const list = drag.text.split(";")
                const plantingId = Number(list[0])
                const sourceLocationId = Number(list[1])
                if (plantingId !== locationView.draggedPlantingId)
                    locationView.draggedPlantingId = plantingId;

                if (model.hasChildren) {
                    if (!model.isExpanded) {
                        locationView.expandIndex = currentIndex
                        locationView.draggedOnIndex = currentIndex
                        locationView.expandTimer.stop();
                        locationView.expandTimer.start();
                    }
                    drag.accepted = (model.indentation >= locationTreeViewModel.depth - 1)
                            && (sourceLocationId === -1);

                } else if (currentLocationId !== sourceLocationId) {
                    drag.accepted = locationSettings.allowPlantingsConflict
                            || Location.acceptPlanting(currentLocationId, plantingId,
                                                       seasonBegin, seasonEnd);
                } else {
                    drag.accepted = false;
                }
            }

            onExited: {
                locationView.draggedPlantingId = -1;
                locationView.draggedOnIndex = null
            }

            onDropped: {
                locationView.draggedPlantingId = -1

                if (drop.hasText && drop.proposedAction == Qt.MoveAction) {
                    const locationId = model.location_id;
                    const list = drop.text.split(";");
                    const plantingId = Number(list[0]);
                    const sourceLocationId = Number(list[1]);

                    drop.acceptProposedAction();

                    let length = 0;
                    if (sourceLocationId > 0) // drag comes from location
                        length = Location.plantingLength(plantingId, sourceLocationId);
                    else
                        length = Planting.lengthToAssign(plantingId);

                    Location.addPlanting(plantingId, model.location_id, length)
                    locationTreeViewModel.refresh(index);

                    locationView.draggedOnIndex = null;
                    locationView.expandIndex = null;
                }
            }
        }

        RowLayout {
            id: layout
            spacing: 0
            anchors.fill: parent
            anchors.leftMargin: 16

            Row  {
                Layout.minimumWidth: firstColumnWidth - 16
                Layout.maximumWidth: firstColumnWidth - 16
                spacing: Units.smallSpacing

                AbstractButton {
                    id: arrowControl
                    height: parent.height
                    width: height
                    Layout.preferredHeight: Units.rowHeight
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignTop

                    onClicked: toggleIsExpanded()

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text: model.hasChildren ? (model.isExpanded ? "\ue313" : "\ue315") : ""
                        font { family: "Material Icons"; pixelSize: 22 }
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                CheckBox {
                    id: rowCheckBox
//                    anchors.verticalCenter: parent.verticalCenter
                    visible: locationView.editMode || locationView.alwaysShowCheckbox
                    height: parent.height * 0.8
                    width: height
                    contentItem: Text {}
                    checked: model.isSelected

                    Layout.preferredHeight: Units.rowHeight
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignTop

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (mouse.button !== Qt.LeftButton)
                                return
                            if (mouse.modifiers & Qt.ControlModifier)
                                model.isTreeSelected = !model.isTreeSelected
                            else
                                model.isSelected = !model.isSelected
                        }
                    }
                }

                ToolButton {
                    id: locationNameLabel
                    text: model.hidden ? "" : (hovered ? "\ue889" : locationSettings.showFullName ? Location.fullName(model.location_id) : model.name)
                    font.family: hovered ? "Material Icons" : "Roboto Regular"
                    font.pixelSize: hovered ? Units.fontSizeTitle : Units.fontSizeBodyAndButton

                    Layout.preferredHeight: Units.rowHeight
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignTop

                    ToolTip.visible: hovered && ToolTip.text
                    ToolTip.text: ""
                    onHoveredChanged: {
                        if (hovered && !ToolTip.text)
                            ToolTip.text = Location.historyDescription(model.location_id, season, year);
                       console.log(ToolTip.text)
                    }
                }

                ConflictAlertButton {
                    id: conflictAlertButton
//                    anchors.verticalCenter: parent.verticalCenter
                    conflictList: model.hidden ? [] : Location.spaceConflictingPlantings(model.location_id, seasonBegin, seasonEnd)
                    year: locationView.year
                    locationId: model.location_id

                    onPlantingModified: {
                        locationTreeViewModel.refresh(currentIndex)
                        timeline.refresh();
                    }
                    onPlantingRemoved: {
                        locationView.plantingRemoved()
                        locationTreeViewModel.refresh(currentIndex)
                        timeline.refresh();
                    }
                }

                ToolButton {
                    id: rotationAlertLabel
                    visible: false
                    //                                visible: locationModel.hasRotationConflict(styleData.index, season, year)
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

            Column {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Repeater {
                    model: locationDelegate.plantingRowList

                    Timeline {
                        id: timeline
                        height: Units.rowHeight
                        visible: locationView.showTimeline
                        year: locationView.year
                        season: locationView.season
                        showGreenhouseSow: false
                        showNames: true
                        //                            showTasks: locationSettings.showTasks
                        showTasks: false
                        showOnlyActiveColor: true
                        showFamilyColor: locationView.showFamilyColor
                        dragActive: true
                        plantingIdList: modelData
                        //                            taskIdList: model.hidden ? []
                        //                                                     : Helpers.intToVariantList(Location.tasks(model.location_id, seasonBegin, seasonEnd) )
                        locationId: currentLocationId
                        onDragFinished: locationView.draggedPlantingId = -1
                        onPlantingMoved: locationTreeViewModel.refresh(currentIndex);
                        onPlantingRemoved: locationTreeViewModel.refresh(currentIndex);
                        Component.onCompleted: {
                            plantingMoved.connect(locationView.plantingMoved)
                            plantingRemoved.connect(locationView.plantingRemoved)
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
           + Units.position(locationView.seasonBegin, plantingEditMode ? editedPlantingPlantingDate
                                                                       : locationView.plantingDate)
        visible: plantingEditMode ||  locationView.draggedPlantingId > 0
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Material.color(Material.Green)
    }

    Rectangle {
        id: plantingEndLine
        width: 2
        x: firstColumnWidth
           + Units.position(locationView.seasonBegin, plantingEditMode ? editedPlantingEndHarvestDate
                                                                       : locationView.endHarvestDate)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: plantingEditMode || locationView.draggedPlantingId > 0
        color: Material.color(Material.Green)
    }

    Timer {
        id: expandTimer
        interval: 300
        onTriggered: {
            if ((locationView.expandIndex > 0)
                    && (locationView.expandIndex === locationView.draggedOnIndex)) {
                locationTreeViewModel.toggleIsExpanded(locationView.expandIndex, true);
                locationView.draggedOnIndex = -1;
            }
        }
    }
}
