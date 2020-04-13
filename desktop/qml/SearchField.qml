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
import QtCharts 2.2

import io.qrop.components 1.0

TextField {
    id: filterField

    property alias filterModel: filterCB.model
    property alias filterIndex: filterCB.currentIndex


    leftPadding: searchLogo.width + 16
    font.family: "Roboto Regular"
    font.pixelSize: Units.fontSizeBodyAndButton
    color: "black"
    placeholderText: qsTr("Search")
    padding: 8
    topPadding: 16
    focus: true
//    implicitHeight: Units.buttonHeight
//    height: Units.buttonHeight

    Keys.onEscapePressed: {
        event.accepted = true
        if (filterField.length)
            filterField.clear()
        else
            filterField.focus = false;

    }
    
    background: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: Units.buttonHeight
        color: Material.color(Material.Grey, Material.Shade400)
        radius: 4
        opacity: 0.1
    }
    
    Label {
        id: searchLogo
        color: Units.colorMediumEmphasis
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: "\ue8b6" // search
        font.family: "Material Icons"
        font.pixelSize: 24
    }

    RoundButton {
        id: clearButton
        flat: true
        visible: filterField.text
        focusPolicy: Qt.NoFocus
        Material.foreground: Material.color(Material.Grey,
                                            Material.Shade500)
        anchors.right: filterModel ? filterCB.left : parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: "\ue5c9" // search
        font.family: "Material Icons"
        font.pixelSize: 24
        onClicked: filterField.clear()
    }

    VerticalThinDivider {
        visible: filterCB.visible
        anchors {
            right: filterCB.left
            top: parent.top
            bottom: parent.bottom
            topMargin: 7
            bottomMargin: 6
        }
    }

    ComboBox {
        id: filterCB
        model: 0
        visible: model
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        flat: true
        editable: false
    }
}
