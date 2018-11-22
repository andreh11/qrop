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

    implicitHeight: childrenRect.height
    model: PlantingModel {
        id: plantingModel
    }
    spacing: 0
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick
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
        height: 40
        spacing: 16

        // This won't work because we don't control creation/deletion of delegates...
        property bool checked: false

        TextCheckBox {
            width: parent.height * 0.8
            visible: !rowDelegate.checked
            selectionMode: false
            text: model.crop
            color: model.crop_color
            round: true
            anchors.verticalCenter: parent.verticalCenter
            //                font.family: "Roboto Regular"
            //                font.pixelSize: 22
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: model.crop + ", " + model.variety
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
            }
            Text {
                text: qsTr("%1 − %2 ⋅ %3 bed m ⋅ %4").arg(NDate.formatDate(model.sowing_date, 2018)).arg(NDate.formatDate(model.end_harvest_date, 2018)).arg(model.length).arg(model.locations)
                font.family: "Roboto Regular"
                color: Material.color(Material.Grey)
                font.pixelSize: 12
            }
        }
    }
}

