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

import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

import io.qrop.components 1.0

Item {
    id: control

    property int season
    property int year
    readonly property var seasonNames: [
        qsTr("Winter"),
        qsTr("Spring"),
        qsTr("Summer"),
        qsTr("Fall")
    ]

    function previousYear() {
        year--;
    }

    function nextYear() {
        year++;
    }

    function previousSeason() {
        if (season === 0) {
            season = 3;
            year--;
        } else {
            season--;
        }
    }

    function nextSeason() {
        if (season === 3) {
            season = 0;
            year++
        } else {
            season++;
        }
    }

    implicitWidth: buttonLayout.implicitWidth
    implicitHeight: Units.buttonHeight

    Rectangle {
        anchors.fill: parent
        //        border.color: Material.accent
        //        border.width: 1
        color: Material.color(Material.Grey, Material.Shade400)
        radius: 4
        opacity: 0.1
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            if (wheel.angleDelta.y > 0) {
                if (wheel.modifiers & Qt.ControlModifier)
                    nextYear();
                else
                    nextSeason();
            } else if (wheel.angleDelta.y < 0) {
                if (wheel.modifiers & Qt.ControlModifier)
                    previousYear();
                else
                    previousSeason();
            }
        }
    }

    RowLayout {
        id: buttonLayout
        anchors.fill: parent
        spacing: Units.smallSpacing

        Label {
            text: seasonNames[season]
            font.family: "Roboto Regular"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 60
            Layout.preferredWidth: 80
        }

        Label {
            text: year
            font.family: "Roboto Regular"
            //            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ColumnLayout {
            spacing: -8
            Layout.rightMargin: 4

            Label {
                id: nextSeasonButton
                text: "\ue5ce"
                font.family: "Material Icons"
                font.pointSize: 16
                color: nextMouseArea.pressed ? Qt.rgba(0,0,0,0.38) : "black"

                MouseArea {
                    id: nextMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if (mouse.modifiers & Qt.ControlModifier)
                            nextYear();
                        else
                            nextSeason();
                    }
                }

                ToolTip.visible: nextMouseArea.containsMouse
                ToolTip.text: qsTr("Next season")
            }

            Text {
                id: previousSeasonButton
                text: "\ue5cf"
                font.family: "Material Icons"
                //            Layout.rightMargin: -16
                font.pointSize: 16
                //            flat: true
                ToolTip.visible: previousMouseArea.containsMouse
                ToolTip.text: qsTr("Previous season")
                color: previousMouseArea.pressed ? Qt.rgba(0,0,0,0.38) : "black"

                MouseArea {
                    id: previousMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        if (mouse.modifiers & Qt.ControlModifier)
                            previousYear();
                        else
                            previousSeason();
                    }
                }
            }

        }
    }
}
