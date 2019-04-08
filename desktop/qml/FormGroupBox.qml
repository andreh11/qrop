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
    id: control

//    padding: Units.formSpacing
    padding: 1
//    topPadding: padding + 8
//    topPadding: Units.mediumSpacing
    width: parent.width

    background: Rectangle {
        height: parent.height
//        width: 10
        width: 0
        implicitWidth: 10
        anchors.topMargin: control.title ? label.height : 0
        color: Material.primary
    }

    label: Label {
        //        x: control.leftPadding
//        x: 10 Units.smallSpacing
        x: 0
        width: control.availableWidth
        text: control.title
        font.family: "Roboto Regular"
        font.pixelSize: 18
        color: Material.primary

    }
}
