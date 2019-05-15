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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

import io.qrop.components 1.0

ListView {
    id: listView

    property int year
    property alias filterString: plantingModel.filterString
    property alias count: plantingModel.rowCount // Number of plantings currently filtered.
    property alias showActivePlantings: plantingModel.showActivePlantings
    property alias showOnlyHarvested: plantingModel.showOnlyHarvested
    property alias cropId: plantingModel.cropId
    property alias week: plantingModel.week
    property alias season: plantingModel.season

    property var selectedIds: ({}) // Map of the ids of the selected plantings
    property var plantingIdList: selectedIdList() // List of the ids of the selected plantings
    property int checks: numberOfTrue(selectedIds) // Number of selected plantings
    property int firstSelectedIndex: -1
    property int secondSelectedIndex: -1

    function selectedIdList() {
        var idList = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
//                selectedIds[key] = false
                idList.push(key)
            }
        return idList;
    }

    function shiftSelectBetween() {
        var min = Math.min(firstSelectedIndex, secondSelectedIndex)
        var max = Math.max(firstSelectedIndex, secondSelectedIndex)

        for (var row = min; row <= max; row++)
            selectedIds[plantingModel.rowId(row)] = true;
        selectedIdsChanged();
        firstSelectedIndex = -1
        secondSelectedIndex = -1
    }

    function selectAll() {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = true;
        selectedIdsChanged();
    }

    function unselectAll() {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = false
        selectedIdsChanged();
    }

    function refresh()  {
       plantingModel.refresh();
    }

    function numberOfTrue(array) {
        var n = 0
        for (var key in array)
            if (array[key])
                n++
        return n
    }

    function reset() {
        // TODO: reset all
        selectedIds = ({});
        plantingModel.refresh();
    }

    clip: true
    implicitHeight: childrenRect.height
    spacing: Units.smallSpacing
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    Keys.onPressed: {
        if (event.key === Qt.Key_Space) {
            if (event.modifiers & Qt.ShiftModifier)
                currentItem.shiftSelect();
            else
                currentItem.select()
        }
    }

    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        visible: listView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }

    model: PlantingModel {
        id: plantingModel
        year: listView.year
    }

    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        visible: largeDisplay && plantingModel.rowCount
        height: listView.height
        policy: ScrollBar.AlwaysOn
    }

    delegate: Row {
        id: rowDelegate
        height: Units.rowHeight
        spacing: Units.smallSpacing

        property bool checked: false

        function select() {
            if (selectedIds[model.planting_id])
                firstSelectedIndex = -1;
            else
                firstSelectedIndex = index;

            selectedIds[model.planting_id] = !selectedIds[model.planting_id];

            secondSelectedIndex = -1;
            selectedIdsChanged();
        }

        function shiftSelect() {
            selectedIds[model.planting_id] = !selectedIds[model.planting_id]
            if (firstSelectedIndex >= 0) {
                secondSelectedIndex = index;
                shiftSelectBetween();
            } else {
                rowDelegate.select();
            }
        }
        TextCheckBox {
            id: checkBox
            width: parent.height * 0.8
            visible: !rowDelegate.checked
            selectionMode: checks > 0
            text: model.crop
            rank: model.planting_rank
            font.pixelSize: 26
            color: model.crop_color
            round: true
            anchors.verticalCenter: parent.verticalCenter
            checked: model.planting_id in selectedIds
                     && selectedIds[model.planting_id]

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (mouse.button !== Qt.LeftButton)
                        return

                    if (mouse.modifiers & Qt.ShiftModifier)
                        rowDelegate.shiftSelect();
                    else
                        rowDelegate.select();
                }
            }
        }

        PlantingLabel {
            anchors.verticalCenter: parent.verticalCenter
            plantingId: model.planting_id
            sowingDate: model.sowing_date
            endHarvestDate: model.end_harvest_date
            year: listView.year
            length: model.length
            locations: model.locations.split(",").map(Number)
            showRank: false
        }
    }
}

