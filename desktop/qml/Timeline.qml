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
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: root

    property int season: 2
    property int year
    property date todayDate: new Date()
    readonly property date seasonBegin: QrpDate.seasonBeginning(season, year)
    property int monthWidth: Units.monthWidth
    readonly property int graphWidth: 12 * monthWidth
    property var plantingIdList
//    property var plantingDrawMapList
    property var taskIdList
    property bool showGreenhouseSow: true
    property bool showOnlyActiveColor: false
    property bool showFamilyColor: false
    property int locationId: -1
    property real locationLength: -1
    property bool showNames: false
    property bool showTasks: false
    property bool showTodayLine: true
    property bool dragActive: false

    signal plantingClicked(int plantingId)
    signal plantingMoved()
    signal plantingRemoved()
    signal dragFinished();

    function refresh() {
        for (var i = 0; i < timegraphView.children.length; i++) {
            if (timegraphView.children[i] instanceof Timegraph)
                timegraphView.children[i].refresh();
        }
    }

    implicitWidth: gridRow.width

    MonthGrid {
        id: gridRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
    }

    Rectangle {
        id: todayLine
        x: Helpers.position(seasonBegin, todayDate)
        z: 3
        visible: root.showTodayLine && x != 0 && x != graphWidth
        width: 1
        anchors.topMargin: -1
        anchors.bottomMargin: -1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.accent
    }

    TaskTimeline {
        id: taskTimeline
        anchors.fill: parent
        visible: showTasks
        model: taskIdList
        seasonBegin: root.seasonBegin
        season: root.season
        year: root.year
    }

    Item {
        id: timegraphView
        anchors.fill: parent
        Repeater {
//            model: plantingDrawMapList
            model: plantingIdList
            delegate: Timegraph {
                plantingId: modelData
//                plantingId: modelData["plantingId"]
//                drawMap: modelData
                locationId: root.locationId
                locationLength: root.locationLength
                todayDate: root.todayDate
                seasonBegin: root.seasonBegin
                season: root.season
                year: root.year
                dragActive: root.dragActive

                showGreenhouseSow: root.showGreenhouseSow
                showNames: root.showNames
                showOnlyActiveColor: root.showOnlyActiveColor
                showFamilyColor: root.showFamilyColor

                onSelected: root.plantingClicked(plantingId)
                onPlantingMoved: root.plantingMoved();
                onPlantingRemoved: root.plantingRemoved();
                onDragFinished: root.dragFinished();
            }
        }
    }
}
