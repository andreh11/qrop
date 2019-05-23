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
import Qt.labs.settings 1.0

CheckBox {
    id: control

    property bool round: false
    property bool selectionMode: false
    property alias color: textBox.color
    property alias rank: rankText.text
    property bool showRank: settings.showPlantingSuccessionNumber

    indicator.visible: hovered || selectionMode
    indicator.x: textBox.x + textBox.width / 2 - indicator.width / 2
    checkable: false

    Settings {
        id: settings
        property bool showPlantingSuccessionNumber
    }

    Rectangle {
        id: textBox
        antialiasing: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        visible: !control.indicator.visible
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
            font.pixelSize: Units.fontSizeSubheading
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

    Rectangle {
        id: rankBox
        visible: textBox.visible && showRank
        antialiasing: true
        anchors.right: parent.right
        anchors.rightMargin: -width/4 -2
        anchors.bottomMargin: width/4
        anchors.bottom: parent.bottom
        width: parent.width*0.5
        height: width
        radius: 50
        color: "white"

        Text {
            id: rankText
            anchors.centerIn: parent
            text: "1"
            color: "black"
            font.family: "Roboto Bold"
            font.pixelSize: 11
        }
    }

    contentItem: Text {}
}
