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

Rectangle {
    id: control

    property alias text: label.text
    property color defaultColor: Material.color(Material.Grey, Material.Shade300)
    property bool hasFocus: false

    implicitWidth: label.implicitWidth + 2 * Units.chipPadding
    implicitHeight: Units.chipHeight

    radius: 32
    color: defaultColor

    Label {
        id: label

        anchors.centerIn: parent
        verticalAlignment: Qt.AlignVCenter

        color: Material.color(Material.Grey, Material.Shade800)
        text: control.text
        font { family: "Roboto Condensed"; pixelSize: Units.fontSizeTable; capitalization: Font.MixedCase }
    }
}
