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

Item {
    id: control

    property int season: 1
    property int year
    property date todayDate: new Date()
    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    property int monthWidth: Units.monthWidth
    readonly property int graphWidth: 12 * monthWidth
    property var plantingIdList
    property bool showGreenhouseSow: true
    property bool showOnlyActiveColor: false
    property int locationId: -1
    property bool showNames: false
    property bool dragActive: false
    property bool showPersistentPlanting: false
    property date persistentPlantingDate
    property date persistentEndHarvestDate

    signal plantingClicked(int plantingId)
    signal plantingMoved()
    signal plantingRemoved()
    signal dragFinished();

    implicitWidth: gridRow.width

    Row {
        id: gridRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: monthWidth - 1

        Repeater {
            model: 13
            Rectangle {
                height: parent.height
                width: 1
                color: Qt.rgba(0, 0, 0, 0.12)
            }
        }
    }

//    Rectangle {
//        id: januaryLine
//        x: Units.position(seasonBegin, new Date(year, 0, 1))
//        visible: x != 0 && x != graphWidth
//        width: 1
//        anchors.top: parent.top
//        anchors.bottom: parent.bottom
//        color: Material.color(Material.Grey, Material.Shade800)
//    }

    Rectangle {
        id: todayLine
        x: Units.position(seasonBegin, todayDate)
        z: 1
        visible: x != 0 && x != graphWidth
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.accent
    }

    Repeater {
        model: plantingIdList
        Timegraph {
            plantingId: modelData
            todayDate: control.todayDate
            seasonBegin: control.seasonBegin
            year: control.year
            showGreenhouseSow: control.showGreenhouseSow
            showNames: control.showNames
            dragActive: control.dragActive
            onSelected: control.plantingClicked(plantingId)
            locationId: control.locationId
            onPlantingMoved:  control.plantingMoved();
            onPlantingRemoved: control.plantingRemoved();
            onDragFinished: control.dragFinished();
            showOnlyActiveColor: control.showOnlyActiveColor
        }
    }
}
