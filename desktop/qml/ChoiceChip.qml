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

    property bool manuallyModified: false
    property color checkedColor: Material.color(Material.Cyan, Material.Shade100)
    property color focusCheckedColor: Material.color(Material.Cyan, Material.Shade300)
    property color activeFocusColor: Material.color(Material.Grey, Material.Shade500)
    property color hoveredColor: Material.color(Material.Grey, Material.Shade400)
    property color defaultColor: Material.color(Material.Grey, Material.Shade300)

    property bool hasFocus: false

    function reset() {
        manuallyModified = false;
    }

    activeFocusOnTab: true
    Keys.onEnterPressed:  if (!checked || !autoExclusive) control.toggle()
    Keys.onReturnPressed:  if (!checked || !autoExclusive) control.toggle()

    // Strangely, we need to do this, because color will not change with activeFocus.
    onActiveFocusChanged: {
        if (activeFocus)
            hasFocus = true
        else
            hasFocus = false
    }
    onToggled: manuallyModified = true

    checkable: true
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    font { family: "Roboto Regular"; pixelSize: 14; capitalization: Font.MixedCase }

    background: Rectangle {
        implicitHeight: Units.chipHeight
        anchors.verticalCenter: control.verticalCenter
        radius: 32
        color: checked ? (hasFocus ? focusCheckedColor : checkedColor)
                       : hasFocus ? activeFocusColor
                                     : hovered ? hoveredColor
                                               : defaultColor
        ColorAnimation on color {
            duration: 2000
        }
    }

    contentItem: Text {
        anchors.verticalCenter: control.verticalCenter
        verticalAlignment: Qt.AlignVCenter

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
        cursorShape: containsMouse && checkable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (checkable && (!autoExclusive || !toggled)) {
                control.toggle()
                manuallyModified = true
                control.clicked()
            }
        }
    }
}
