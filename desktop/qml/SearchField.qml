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
import QtCharts 2.2

import io.croplan.components 1.0
import "date.js" as MDate

TextField {
    id: filterField
    leftPadding: searchLogo.width + 16
    font.family: "Roboto Regular"
    font.pixelSize: Units.fontSizeBodyAndButton
    color: "black"
    placeholderText: qsTr("Search")
    padding: 8
    topPadding: 16
    focus: true
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            filterMode = false
            filterField.text = ""
        }
    }
    
    background: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 200
        implicitHeight: 20
        //                        width: parent.width
        height: parent.height * 0.7
        color: Material.color(Material.Grey,
                              Material.Shade400)
        radius: 4
        opacity: 0.1
    }
    
    Label {
        id: searchLogo
        //                    visible: filterField.visible
        color: "black"
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
        Material.foreground: Material.color(Material.Grey,
                                            Material.Shade500)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: "\ue5c9" // search
        font.family: "Material Icons"
        font.pixelSize: 24
        onClicked: filterField.clear()
    }

}
