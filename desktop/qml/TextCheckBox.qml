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

CheckBox {
    id: control

    property bool round: false
    property bool selectionMode: false
    property alias color: textBox.color

    indicator.visible: hovered || selectionMode
    indicator.x: textBox.x + textBox.width / 2 - indicator.width / 2

    Rectangle {
        id: textBox
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            visible: !hovered && !selectionMode
            width: parent.width
            height: width
            radius: round ? 50 : 4
            color:  Material.color(Material.Green, Material.Shade400)
            Text {
                visible: !control.checked && !hovered
                anchors.centerIn: parent
                text: control.text.slice(0,2)
                color: "white"
                font.family: "Roboto Bold"
                font.pixelSize: Units.fontSizeBodyAndButton
            }
            Text {
                visible: control.checked || hovered
                anchors.centerIn: parent
                text: "\ue876"
                color: "white"
                font.family: "Material Icons"
                font.pixelSize: 16
            }
        }

    contentItem: Text {}
//        text: control.text
//        font: control.font
//        opacity: enabled ? 1.0 : 0.3
//        color: control.down ? "#17a81a" : "#21be2b"
//        verticalAlignment: Text.AlignVCenter
//        leftPadding: control.indicator.width + control.spacing
//    }
}
