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
    id: greenhouseBox
    padding: 0
    topPadding: title === "" ? 0 : 32
    bottomPadding: 16
    width: parent.width
    background: Rectangle { anchors.fill: parent }
    label: Label {
        y: 0
        width: greenhouseBox.leftPadding
        text: greenhouseBox.title
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeSubheading
        color: Material.accent
    }
}
