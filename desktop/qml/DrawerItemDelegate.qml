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
import QtGraphicalEffects 1.0

ItemDelegate {
    id: control

    property string page
    property bool isActive: index === navigationIndex
    property alias iconText: iconLabel.text
    property alias iconColor: iconLabel.color
    property bool showToolTip: true

    focusPolicy: Qt.NoFocus
//    height: 72
//    width: 72
    implicitHeight: 56
    implicitWidth: 72
//    highlighted: isActive
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter

    ToolTip {
        x: control.width + Units.smallSpacing
        y: (control.height - height) / 2
        text: control.text
        visible: control.showToolTip && largeDisplay && control.hovered
        delay: Qt.styleHints.mousePressAndHoldInterval
    }


   contentItem: Item {
       anchors.fill: parent

    Label {
        id: iconLabel
        width: 24
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: isActive ? 14 : 16
        }
        color: isActive ? Material.accent : Units.colorMediumEmphasis
        font.family: "Material Icons"
        font.pixelSize: 22
        horizontalAlignment: largeDisplay && railMode ? Text.AlignHCenter : Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    Label {
        id: textLabel
        visible: isActive
        width: Math.min(parent.width - 2, implicitWidth)
        text: control.text
        font.family: "Roboto Condensed"
        font.pixelSize: Units.fontSizeBodyAndButton
        elide: Text.ElideRight
        //            color: "white"
        color: iconLabel.color
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: iconLabel.bottom
            topMargin: 2
        }

        //            visible: !largeDisplay
        //            width: visible ? implicitWidth : 0
        //            height:
        verticalAlignment: Text.AlignVCenter
    }
   }

}
