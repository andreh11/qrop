/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.0

Button {
    id: control
    checkable: true

    property bool manuallyModified: false
    property color checkedColor: Material.color(Material.Grey, Material.Shade300)
    property color focusCheckedColor: Material.color(Material.Indigo, Material.Shade300)
    property color activeFocusColor: Material.color(Material.Grey, Material.Shade500)
    property color hoveredColor: Material.color(Material.Grey, Material.Shade100)
    property color defaultColor: "white"

    property bool hasFocus: false

    font {
        family: "Roboto Regular"
        pixelSize: Units.fontSizeBodyAndButton
        capitalization: Font.MixedCase
    }

    contentItem: Text {
        anchors.verticalCenter: control.verticalCenter
        verticalAlignment: Qt.AlignVCenter

        color: Units.colorHighEmphasis
        text: control.text
        font: control.font

        Behavior on color {
            ColorAnimation { duration: Units.shortDuration  }
        }
    }

    background: Rectangle {
        implicitHeight: Units.chipHeight
        anchors.verticalCenter: control.verticalCenter
        radius: 0
        border.width: 1
        border.color: checked ? Material.color(Material.Grey, Material.Shade500)
                              : Material.color(Material.Grey, Material.Shade300)
        color: checked ? (hasFocus ? focusCheckedColor : checkedColor)
                       : hasFocus ? activeFocusColor
                                  : hovered ? hoveredColor
                                            : defaultColor
    }
}
