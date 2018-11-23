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

import io.croplan.components 1.0

ListView {
    id: listView

    property alias filterString: plantingModel.filterString
    property alias count: plantingModel.count // Number of plantings currently filtered.

    property var selectedIds: ({}) // Map of the ids of the selected plantings
    property var plantingIdList: selectedIdList() // List of the ids of the selected plantings
    property int checks: numberOfTrue(selectedIds) // Number of selected plantings
    property int lastIndexClicked: -1 // TODO: fors shift selection

    function selectedIdList() {
        var idList = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
//                selectedIds[key] = false
                idList.push(key)
            }
        return idList;
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
        selectedIds = ({})
    }

    clip: true
    implicitHeight: childrenRect.height
    spacing: Units.smallSpacing
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick

    model: PlantingModel {
        id: plantingModel
    }

    Keys.onUpPressed: verticalScrollBar.decrease()
    Keys.onDownPressed: verticalScrollBar.increase()

    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        visible: largeDisplay && plantingModel.count
        height: listView.height
        policy: ScrollBar.AlwaysOn
    }

    delegate: Row {
        id: rowDelegate
        height: Units.rowHeight
        spacing: Units.formSpacing

        property bool checked: false

        TextCheckBox {
            width: parent.height
            visible: !rowDelegate.checked
            selectionMode: checks > 0
            text: model.crop
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

                    selectedIds[model.planting_id] = !selectedIds[model.planting_id]
                    lastIndexClicked = index
                    selectedIdsChanged()
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "%1, %2".arg(model.crop).arg(model.variety)
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
            }
            Text {
                text: qsTr("%1 − %2 ⋅ %3 bed m ⋅ %4").arg(NDate.formatDate(model.sowing_date, 2018)).arg(NDate.formatDate(model.end_harvest_date, 2018)).arg(model.length).arg(model.locations)
                font.family: "Roboto Regular"
                color: Material.color(Material.Grey, Material.Shade600)
                font.pixelSize: Units.fontSizeCaption
            }
        }
    }
}

