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

GroupBox {
    id: control

    padding: Units.formSpacing
//    topPadding: padding + 8
//    topPadding: title === "" ? 0 : 32
    width: parent.width

    background: Rectangle {
        anchors.fill: parent
        radius: 4
        anchors.topMargin: control.title ? label.height : 0
        border.color: Material.color(Material.Grey, Material.Shade300)
    }

    label: Label {
        x: control.leftPadding
        width: control.availableWidth
        text: control.title
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        color: Material.primary

    }
}
