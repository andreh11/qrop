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

Item {
    id: control

    property bool condensed: false
    property alias text: headerLabel.text
    property Item container

    property int horizontalAlignment: Text.AlignLeft
    signal newColumn(int column)
    signal newOrder(string order)

    height: headerLabel.height
    anchors.verticalCenter: parent.verticalCenter

    Label {
        id: iconLabel
        transformOrigin: Item.Center
        text: "\ue5db"
        visible: mouseArea.containsMouse
        horizontalAlignment: control.horizontalAlignment
        color: Units.colorMediumEmphasis
        font.family: "Material Icons"
        font.pixelSize: 16
        anchors.left: horizontalAlignment === Text.AlignLeft ? headerLabel.right : undefined
        anchors.right: horizontalAlignment === Text.AlignRight ? headerLabel.left : undefined
        rotation: 0
    }

    Label {
        id: headerLabel
        width: Math.min(implicitWidth, parent.width - iconLabel.width)
        anchors.left: horizontalAlignment === Text.AlignLeft ? parent.left : undefined
        anchors.right: horizontalAlignment === Text.AlignRight ? parent.right : undefined
        elide: Text.ElideRight
        color: Units.colorMediumEmphasis
        font.family: condensed ? "Roboto Condensed" : "Roboto Regular"
        font.pixelSize: Units.fontSizeTable
        horizontalAlignment: control.horizontalAlignment
    }

    ToolTip {
        visible: mouseArea.containsMouse && headerLabel.implicitWidth > headerLabel.width
        delay: Qt.styleHints.mousePressAndHoldInterval
        text: control.text
        font.family: "Roboto Regular"
        x: headerLabel.width / 2
        y: headerLabel.height + 16
    }

    state: ""
    states: [
        State {
            name: ""
            PropertyChanges {
                target: iconLabel
                visible: mouseArea.containsMouse
                color: Units.colorMediumEmphasis
                rotation: 0
            }
            PropertyChanges {
                target: headerLabel
                color: mouseArea.containsMouse ? Units.colorHighEmphasis : Units.colorMediumEmphasis
            }
        },

        State {
            name: "descending"
            PropertyChanges {
                target: iconLabel
                visible: true
                rotation: 0
                color: Units.colorHighEmphasis
            }
            PropertyChanges {
                target: headerLabel
                color: Units.colorHighEmphasis
            }

        },

        State {
            name: "ascending"
            PropertyChanges {
                target: iconLabel
                visible: true
                text: "\ue5db"
                rotation: 180
                color: Units.colorHighEmphasis
            }
            PropertyChanges {
                target: headerLabel
                color: Units.colorHighEmphasis
            }
        }
    ]

    transitions: [
        Transition {
            from: "descending"; to: "ascending"

            RotationAnimation {
                target: iconLabel
                duration: Units.mediumDuration
            }
        },

        Transition {
            from: "ascending"; to: "descending"

            RotationAnimation {
                target: iconLabel
                duration: Units.mediumDuration
            }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            switch (control.state) {
            case "":
                newColumn(index);
                break
            case "descending":
                newOrder("ascending")
                break;
            case "ascending":
                newOrder("descending")
                break;
            }
        }
    }
}
