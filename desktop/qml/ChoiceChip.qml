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

Button {
    id: control
    checkable: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset
    padding: 8
    hoverEnabled: true

    background: Rectangle {
        implicitHeight: Units.chipHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: 32
        color: checked ? Material.color(Material.Cyan, Material.Shade100) :
                         activeFocus ? Material.color(Material.Grey, Material.Shade500) :
                                       hovered ? Material.color(Material.Grey, Material.Shade400) :
                                                 Material.color(Material.Grey, Material.Shade300)
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: leftPadding

        color: checked ? Material.color(Material.Blue, Material.Shade800)
                       : Material.color(Material.Grey, Material.Shade800)
        text: control.text
        font.family: "Roboto Regular"
        font.pixelSize: 14

        ColorAnimation on color {
            duration: 2000
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (!checked || !autoExclusive) control.toggle()
    }
}
