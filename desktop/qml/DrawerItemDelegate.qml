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
import QtGraphicalEffects 1.0

ItemDelegate {
    id: control

    property string page
    property bool isActive: index === navigationIndex
    property alias iconText: iconLabel.text
    property alias iconColor: iconLabel.color
    property bool showToolTip: true

    focusPolicy: Qt.NoFocus
    height: 48
    highlighted: isActive
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter

    ToolTip {
        x: control.width + Units.smallSpacing
        y: (control.height - height) / 2
        text: control.text
        visible: control.showToolTip && largeDisplay && control.hovered
        delay: Qt.styleHints.mousePressAndHoldInterval
    }

    contentItem: Row {
        anchors.centerIn: parent
        spacing: largeDisplay && railMode ? 0 : 24

        Label {
            id: iconLabel
            color: "white"
            width: 28
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Material Icons"
            font.pixelSize: 28
            horizontalAlignment: largeDisplay && railMode ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Label {
            id: textLabel
            text: control.text
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            visible: !largeDisplay
            width: visible ? implicitWidth : 0
            font.family: "Roboto Regular"
            verticalAlignment: Text.AlignVCenter
        }
    }

}
