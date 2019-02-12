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

    property int season: 0
    property int year: 2018
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
        if (season == MDate.WINTER) {
            season = MDate.FALL;
            year--;
        } else {
            season--;
        }
    }

    function nextSeason() {
        if (season == MDate.FALL) {
            season = MDate.WINTER;
            year++
        } else {
            season++;
        }
    }

    implicitHeight: buttonLayout.implicitHeight
    implicitWidth: buttonLayout.implicitWidth
    height: implicitHeight
    width: implicitWidth

    RowLayout {
        id: buttonLayout
        anchors.fill: parent
        spacing: Units.smallSpacing

        RoundButton {
            id: previousYearButton
            text: "\ue314"
            font.family: "Material Icons"
            font.bold: true
            font.pointSize: 20
            Material.foreground: Material.accent
            Layout.rightMargin: -32
            onClicked: year--
            flat: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Previous year")
        }

        RoundButton {
            id: previousSeasonButton
            text: "\ue314"
            font.family: "Material Icons"
            Layout.rightMargin: -16
            font.pointSize: 20
            onClicked: previousSeason()
            flat: true
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Previous season")
        }

        Label {
            text: seasonNames[season]
            font.family: "Roboto Regular"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: 60
            Layout.preferredWidth: width
        }

        Label {
            text: year
            font.family: "Roboto Regular"
            //            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        RoundButton {
            id: nextSeasonButton
            text: "\ue315"
            font.family: "Material Icons"
            font.pointSize: 20
            Layout.leftMargin: -16
            flat: true
            onClicked: nextSeason()
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Next season")
        }

        RoundButton {
            id: nextYearButton
            text: "\ue315"
            font.family: "Material Icons"
            font.bold: true
            Material.foreground: Material.accent
            font.pointSize: 20
            Layout.leftMargin: -32
            flat: true
            onClicked: year++
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Next year")
        }
    }
}
