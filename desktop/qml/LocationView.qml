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
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: view

    property alias year: locationModel.year
    property alias season: locationModel.season

    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    property date todayDate: new Date()
    property int firstColumnWidth
    property int editedPlantingId: -1

    property alias rowCount: locationModel.rowCount
    property alias showOnlyEmptyLocations: locationModel.showOnlyEmptyLocations
    property alias showOnlyGreenhouseLocations: locationModel.showOnlyGreenhouseLocations
    property alias hasSelection: selectionModel.hasSelection
    property alias selectedIndexes: selectionModel.selectedIndexes
    property alias draggedPlantingId: treeView.draggedPlantingId
    property bool showFamilyColor: false

    property alias treeDepth: locationModel.depth
    property int headerHeight: headerRow.height
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
        locationModel.refreshTree();
    }

    function reload() {
        locationModel.refresh();
    }

    function updateIndexes(map, indexes) {
        locationModel.updateIndexes(map, indexes);
    }

    // TODO: optimize
    function selectAll() {
        console.time("selectAll")
        selectionModel.select(locationModel.treeSelection(), ItemSelectionModel.Select);
        //        console.log(l);
        //        for (var i = 0; i < l.length; i++) {
        //            selectionModel.select(l[i], ItemSelectionModel.Select)
        ////        }
        locationModel.refreshTree();
        console.timeEnd("selectAll")
    }

    function deselectAll() {
        selectionModel.clear();
        locationModel.refreshTree();
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
            locationModel.refreshIndex(selectedIndexes[j]);
    }

    function selectLocationIds(idList) {
        var indexList = locationModel.treeHasIds(idList);

        for (var i = 0; i < indexList.length; i++) {
            var idx = indexList[i];
            selectionModel.select(idx, ItemSelectionModel.Select);
            expandPath(idx);

            if (editedPlantingId > 0)
                assignedLengthMap[idx] = locationModel.plantingLength(editedPlantingId, idx);
        }
        assignedLengthMapChanged();
    }

    //! Expand all nodes from root to index's parent.
    function expandPath(index) {
        var path = locationModel.treePath(index);
        for (var i = 0; i < path.length; i++) {
            if (!treeView.isExpanded(path[i]))
                treeView.expand(path[i]);
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

    function addLocations(name, length, width, quantity) {
        if (view.hasSelection)
            locationModel.addLocations(name, length, width, quantity, selectionModel.selectedIndexes)
        else
            locationModel.addLocations(name, length, width, quantity)
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


    Settings {
        id: locationSettings
        category: "LocationView"
        property bool showFullName
        property bool allowPlantingsConflict
        property bool showTasks
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
        id: todayLine
        x: firstColumnWidth + Units.position(seasonBegin, todayDate)
        z: 1
        visible: x !== 0 && x !== Units.graphWidth
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.accent
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
            leftPadding: 16 + view.indentation

            CheckBox {
                id: headerRowCheckBox
                anchors.verticalCenter: headerRow.verticalCenter
                visible: view.editMode
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
                        view.deselectAll()
                        return Qt.Unchecked
                    } else {
                        view.selectAll()
                        return Qt.Checked
                    }
                }
            }

            TableHeaderLabel {
                text: qsTr("Name")
                width: 120 - (view.editMode ? headerRowCheckBox.width + headerRow.spacing : 0)
            }

            Row {
                id: headerTimelineRow
                visible: view.showTimeline
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height

                Repeater {
                    model: monthsOrder[view.season]
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

    Controls1.TreeView {
        id: treeView
        //                anchors.fill: parent
        anchors {
            top: headerRectangle.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        // Size of the area of the bottom and top of TreeView where the drag-scrolling
        // happens.
        property int scrollEdgeSize: Units.rowHeight

        // Internal: set to -1 when drag-scrolling up and 1 when drag-scrolling down
        property int _scrollingDirection: 0

        property int draggedPlantingId: -1
        property date plantingDate: Planting.plantingDate(draggedPlantingId)
        property date endHarvestDate: Planting.endHarvestDate(draggedPlantingId)
        readonly property date seasonBegin: MDate.seasonBeginning(view.season,
                                                                  view.year)

        property var expandIndex: null
        property var draggedOnIndex: null
        property alias expandTimer: expandTimer

//        DropArea {
//            anchors.top: parent.top
//            anchors.left: parent.left
//            anchors.right: parent.right
//            height: 16
//            onEntered: {
//                if (!upAnimation.running)
//                    upAnimation.start();
//            }
//            onPositionChanged: {
//                if (!upAnimation.running)
//                    upAnimation.start();
//            }

//            onExited: upAnimation.stop()
//        }

//        DropArea {
//            anchors.bottom: parent.bottom
//            anchors.left: parent.left
//            anchors.right: parent.right
//            height: 16
//            onEntered: {
//                if (!downAnimation.running)
//                    downAnimation.start();
//            }
//            onPositionChanged: {
//                if (!downAnimation.running)
//                    downAnimation.start();
//            }
//            onExited: downAnimation.stop()
//        }

        // BUG: badly crashing, don't know why
//        NumberAnimation {
//            id: upAnimation
//            target: treeView.__listView
//            property: "contentY"
//            to: Math.max(0, treeView.__listView.contentY - Units.rowHeight)
//            duration: 50
//        }

//        NumberAnimation {
//            id: downAnimation
//            target: treeView.__listView
//            property: "contentY"
//            to: Math.min(treeView.__listView.contentHeight - treeView.__listView.height,
//                         treeView.__listView.contentY + Units.rowHeight)
//            duration: 50
//        }

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
            indentation: view.indentation
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
                width: view.indentation
                height: Units.rowHeight + 1
                x: - styleData.depth * view.indentation

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
            id: itemDelegate
            property int locationId: locationModel.locationId(styleData.index)

            function scrollIfNeeded(yDrag) {
                var yCoord = treeView.mapFromItem(dropArea, 0, yDrag).y
                if (yCoord < Units.rowHeight) {
                    if (!upAnimation.running)
                        upAnimation.start();
                } else if (yCoord > treeView.height - Units.rowHeight) {
                    if (!downAnimation.running)
                        downAnimation.start();
                }
            }

            Rectangle {
                width: parent.width - x
                height: Units.rowHeight + 1
                color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                                 selectionModel.isSelected(styleData.index) ? 1.1 :  1)

                x: - styleData.depth * view.indentation

                DropArea {
                    id: dropArea
                    anchors.fill: parent

//                    onPositionChanged: itemDelegate.scrollIfNeeded(drag.y)
                    onEntered: {
                        // TODO: crashing unexpectedly when scrolling, don't know why.
                        // itemDelegate.scrollIfNeeded(drag.y)

                        var list = drag.text.split(";")
                        var plantingId = Number(list[0])
                        var sourceLocationId = Number(list[1])
                        if (plantingId !== treeView.draggedPlantingId)
                            treeView.draggedPlantingId = plantingId;

                        if (styleData.hasChildren) {
                            if (!styleData.isExpanded) {
                                treeView.expandIndex = styleData.index
                                treeView.draggedOnIndex = styleData.index
                                treeView.expandTimer.stop();
                                treeView.expandTimer.start();
                            }
                            drag.accepted = (styleData.depth >= locationModel.depth - 1)
                                    && (sourceLocationId === -1);

                        } else if (locationId !== sourceLocationId) {
                            drag.accepted = locationSettings.allowPlantingsConflict
                                    || locationModel.acceptPlanting(styleData.index, plantingId);
                        } else {
                            drag.accepted = false;
                        }
                    }

                    onExited: {
                        treeView.draggedPlantingId = -1;
                        treeView.draggedOnIndex = null
//                        treeView._scrollingDirection = 0

//                        if (upAnimation.running) {
//                            upAnimation.stop();
//                        }

//                        if (downAnimation.running) {
//                            downAnimation.stop();
//                        }
                    }

                    onDropped: {
                        treeView.draggedPlantingId = -1

                        if (//!styleData.hasChildren
                                drop.hasText
                                && drop.proposedAction == Qt.MoveAction) {

                            var locationId = locationModel.locationId(styleData.index)
                            var list = drop.text.split(";")
                            var plantingId = Number(list[0])
                            var sourceLocationId = Number(list[1])

                            drop.acceptProposedAction()

                            var length = 0;
                            if (sourceLocationId > 0) // drag comes from location
                                length = Location.plantingLength(plantingId, sourceLocationId)
                            else
                                length = Planting.lengthToAssign(plantingId)
                            locationModel.addPlanting(styleData.index, plantingId, length)

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
                        if (styleData.hasChildren || !view.plantingEditMode)
                            return;

                        var plantings = locationModel.plantings(styleData.index, view.season, view.year)
                        if (!selectionModel.isSelected(styleData.index)
                                && !locationModel.acceptPlanting(styleData.index,
                                                                 editedPlantingPlantingDate,
                                                                 editedPlantingEndHarvestDate)
                                && !plantings.includes(editedPlantingId)) {
                            return;
                        }

                        if (selectionModel.isSelected(styleData.index)) {
                            assignedLengthMap[styleData.index] = 0
                        } else if (plantings.includes(editedPlantingId)) {
                            assignedLengthMap[styleData.index] =
                                    locationModel.plantingLength(editedPlantingId, styleData.index);

                        } else {
                            var availableSpace = locationModel.availableSpace(styleData.index,
                                                                              editedPlantingPlantingDate,
                                                                              editedPlantingEndHarvestDate);

                            if (remainingLength === 0) {
                                assignedLengthMap[styleData.index] = availableSpace;
                                view.addPlantingLength(assignedLengthMap[styleData.index]);
                            } else {
                                assignedLengthMap[styleData.index] = Math.min(remainingLength, availableSpace);
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
                                visible: view.editMode || view.alwaysShowCheckbox
                                height: parent.height * 0.8
                                width: height
                                contentItem: Text {}
                                checked: selectionModel.isSelected(styleData.index)

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
                                text: hovered ? "\ue889"
                                              : locationSettings.showFullName
                                                ? Location.fullName(locationModel.locationId(styleData.index))
                                                : styleData.value
                                font.family: hovered ? "Material Icons" : "Roboto Regular"
                                font.pixelSize: hovered ? Units.fontSizeTitle : Units.fontSizeBodyAndButton

                                ToolTip.visible: hovered && ToolTip.text
                                ToolTip.text: ""
                                onHoveredChanged: {
                                    if (hovered && !ToolTip.text)
                                        ToolTip.text = locationModel.historyDescription(styleData.index, season, year)
                                }
                            }

                            Item {
                                id: namePadder
                                height: Units.rowHeight
                                width: 120 - locationNameLabel.width - row.spacing
                                       - (rowCheckBox.visible
                                          ? rowCheckBox.width + row.spacing
                                          : 0)
                                       - (conflictAlertButton.visible
                                          ? conflictAlertButton.width + row.spacing
                                          : 0)
                                       - (rotationAlertLabel.visible
                                          ? rotationAlertLabel.width + row.spacing
                                          : 0)

                            }

                            ConflictAlertButton {
                                id: conflictAlertButton
                                anchors.verticalCenter: parent.verticalCenter
                                visible: false
                                conflictList: []
//                                visible: locationModel.hasSpaceConflict(styleData.index, season, year)
//                                conflictList: visible ? [] : locationModel.spaceConflictingPlantings(styleData.index, season, year)
                                year: view.year
                                locationId: locationModel.locationId(styleData.index)
                                onPlantingModified: {
                                    locationModel.refreshIndex(styleData.index)
                                    timeline.refresh();
                                }
                                onPlantingRemoved: {
                                    view.plantingRemoved()
                                    locationModel.refreshIndex(styleData.index)
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
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on opacity { NumberAnimation { duration: Units.longDuration } }
                                ToolTip.visible: hovered && ToolTip.text
                                ToolTip.text: ""

                                onHoveredChanged: {
                                    if (hovered && !ToolTip.text)
                                        ToolTip.text = locationModel.rotationConflictingDescription(styleData.index, season, year)
                                }
                            }

                            Timeline {
                                id: timeline
                                height: parent.height
                                visible: view.showTimeline
                                year: view.year
                                season: view.season
                                showGreenhouseSow: false
                                showNames: true
                                showTasks: locationSettings.showTasks
                                showOnlyActiveColor: true
                                showFamilyColor: view.showFamilyColor
                                dragActive: true
                                plantingIdList: locationModel.plantings(styleData.index, season, year)
                                taskIdList: locationModel.tasks(styleData.index, season, year)
                                locationId: locationModel.locationId(styleData.index)
                                onDragFinished: treeView.draggedPlantingId = -1
                                onPlantingMoved: {
                                    locationModel.refreshIndex(styleData.index)
                                    view.plantingMoved()
                                }
                                onPlantingRemoved: {
                                    locationModel.refreshIndex(styleData.index)
                                    view.plantingRemoved()
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
