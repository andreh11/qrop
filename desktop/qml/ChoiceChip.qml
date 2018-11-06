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

    property color checkedColor: Material.color(Material.Cyan, Material.Shade100)
    property color activeFocusColor: Material.color(Material.Grey, Material.Shade500)
    property color hoveredColor: Material.color(Material.Grey, Material.Shade400)
    property color defaultColor: Material.color(Material.Grey, Material.Shade300)

    checkable: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset
    padding: 8
    hoverEnabled: true
    font { family: "Roboto Regular"; pixelSize: 14; capitalization: Font.MixedCase }


    background: Rectangle {
        implicitHeight: Units.chipHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: 32
        color: checked ? checkedColor
                       : activeFocus ? activeFocusColor
                                     : hovered ? hoveredColor
                                               : defaultColor
        ColorAnimation on color {
            duration: 2000
        }
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: leftPadding

        color: checked ? Material.color(Material.Blue, Material.Shade800)
                       : Material.color(Material.Grey, Material.Shade800)
        text: control.text
        font: control.font

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
