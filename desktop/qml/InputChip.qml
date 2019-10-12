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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Rectangle {
    id: control

    property string text
    signal deleted()

    implicitHeight: 32
    radius: 40
    implicitWidth: contentLabel.width + deleteButton.width
    color:  control.activeFocus
            ? Material.color(Material, Material.Shade500)
            : mouseArea.hovered ? Material.color(Material, Material.Shade400) :
                                Material.color(Material.Grey, Material.Shade300)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Label {
        id: contentLabel
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        color:  Material.color(Material.Grey, Material.Shade800)
        text: control.text
        font.family: "Roboto Regular"
        font.pixelSize: 14
    }

    RoundButton {
        id: deleteButton
        flat: true
        anchors.right: parent.right
        anchors.rightMargin: -8
        anchors.verticalCenter: parent.verticalCenter
        Material.foreground: Material.color(Material.Grey,
                                            Material.Shade500)
        text: "\ue5c9" // remove
        font.family: "Material Icons"
        font.pixelSize: 24
        onClicked: deleted()
    }
}
