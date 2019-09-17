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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: control

    property int plantingId
    readonly property bool validId: plantingId > 0
    property var map: Planting.mapFromId("planting_view", plantingId)
    property string crop: map['crop']
    property string variety: map['variety']
    property date sowingDate: map['sowing_date']
    property date endHarvestDate: map['end_harvest_date']
    property int rank: map['planting_rank']
    property int year
    property var locations
    property double length
    property bool showOnlyDates: false
    property bool showRank: false

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    Settings {
        id: settings
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
    }

    Column {
        id: column

        Text {
            text: validId ? "%1, %2".arg(crop).arg(variety) : " "
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeTable
            elide: Text.ElideRight
        }

        Text {
            text: {
                var txt = ""

                if (showRank && settings.showPlantingSuccessionNumber) {
                    txt += "#%1 ".arg(rank)
                }

                txt += qsTr("%1−%2").arg(MDate.formatDate(sowingDate, year)).arg(MDate.formatDate(endHarvestDate, year))

                if (!showOnlyDates) {
                    if (settings.useStandardBedLength) {
                        var beds = length/settings.standardBedLength
                        txt += qsTr(" ⋅ %L1 bed ⋅ %2", "", beds).arg(beds).arg(Location.fullName(locations))
                    } else {
                        txt += qsTr(" ⋅ %L1 bed m ⋅ %2").arg(length).arg(Location.fullName(locations))
                    }
                }
                return txt;
            }
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeTable
            color: Units.colorMediumEmphasis
            elide: Text.ElideRight
        }
    }
}
