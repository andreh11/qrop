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
import QtCharts 2.0

import io.qrop.components 1.0

MSpinBox {
    id: control
    editable: true
    font.family: "Roboto Regular"
    font.pixelSize: 16

    contentItem: TextInput {
        padding: 0
        text: control.textFromValue(control.value, control.locale)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: up.indicator.right
        anchors.leftMargin: 8

        font: control.font
        color: "black"
        selectionColor: "#21be2b"
        selectedTextColor: "#ffffff"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        //        x: control.mirrored ? 0 : parent.width - width
        //        x: control.mirrored ? parent.width : 0
        anchors.left: down.indicator.right
        anchors.leftMargin: 0
        implicitWidth: 24

        height: width
        color: control.up.pressed ? "#e4e4e4" : "transparent"
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "\ue315"
            font.family: "Material Icons"
            font.pixelSize: 24
            color: enabled ? control.Material.foreground : control.Material.spinBoxDisabledIconColor
            anchors.fill: parent
            //            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 24
        height: width
        color: control.down.pressed ? "#e4e4e4" : "transparent"

        Text {
            text: "\ue314"
            font.family: "Material Icons"
            font.pixelSize: 24
            color: enabled ? control.Material.foreground : control.Material.spinBoxDisabledIconColor
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Item {
        implicitWidth: parent.width
        implicitHeight: 48

        Rectangle {
            x: parent.width / 2 - width / 2
            y: parent.y + parent.height - height - control.bottomPadding / 2
//            width: control.availableWidth
            height: 0
            color: control.activeFocus ? control.Material.accentColor : control.Material.hintTextColor
        }
    }

}
