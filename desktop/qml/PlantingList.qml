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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0
import "date.js" as MDate

ListView {
    id: listView
    model: PlantingModel { }

    delegate: Row {
        id: rowDelegate
        height: 64
        spacing: 16
        leftPadding: 16
        topPadding: 16

        // This won't work because we don't control creation/deletion of delegates...
        property bool checked: false

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: height
            radius: 80
            color: Material.color(Material.Green, Material.Shade400)

            MouseArea {
                anchors.fill: parent
                onClicked: checked = !checked
            }

            Text {
                visible: !rowDelegate.checked
                anchors.centerIn: parent
                text: model.crop.slice(0,2)
                color: "white"
                font.family: "Roboto Regular"
                font.pixelSize: 24
            }
            Text {
                visible: rowDelegate.checked
                anchors.centerIn: parent
                text: "\ue876"
                color: "white"
                font.family: "Material Icons"
                font.pixelSize: 24
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: model.crop + ", " + model.variety
                font.family: "Roboto Regular"
                font.pixelSize: fontSizeBodyAndButton
            }
            Text {
                text: MDate.formatDate(model.sowing_date) + " − " + MDate.week(model.end_harvest_date) + ", " + model.place_ids
                font.family: "Roboto Regular"
                color: Material.color(Material.Grey)
                font.pixelSize: 12
            }
        }
    }
}

