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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Label {
    id: label

    property bool showToolTip: false

    font.family: "Roboto Condensed"
    font.pixelSize: Units.fontSizeBodyAndButton

//    ToolTip {
//        visible: showToolTip && mouseArea.containsMouse
//        delay: Qt.styleHints.mousePressAndHoldInterval
//        text: label.text
//        font.family: "Robo Regular"
//        x: label.width / 2
//        y: label.height + 16
//    }

//    MouseArea {
//        id: mouseArea
//        anchors.fill: parent
//        hoverEnabled: true
//        propagateComposedEvents: true
//        acceptedButtons: Qt.NoButton
//    }
}
