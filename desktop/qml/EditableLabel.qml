/*
 * Copyright (C) 2019 André Hoarau <ah@ouvaton.org>
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
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    id: control

    property alias text: textField.text
    property alias inputMethodHints: textField.inputMethodHints
    property alias validator: textField.validator
    property alias horizontalAlignment: textField.horizontalAlignment
    property alias color: label.color

    signal editingFinished()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: true
        onDoubleClicked: control.state = "edit"
        onPressAndHold: controle.state = "edit" // for Android
    }

    Label {
        id: label
        elide: Text.ElideRight
        font.family: "Roboto Regular"
        color: Units.colorHighEmphasis
        font.pixelSize: Units.fontSizeBodyAndButton
        text: control.text
        anchors.verticalCenter: parent.verticalCenter
    }

    TextField {
        id: textField

        property string oldText: ""

        visible: false
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        anchors.verticalCenter: parent.verticalCenter

        onVisibleChanged: if (visible) forceActiveFocus();
        onActiveFocusChanged: oldText = text

        onEditingFinished: {
            control.state = "display";
            control.editingFinished();
        }

        Keys.onEscapePressed: {
            text = oldText;
            control.state = "display";
        }
    }

    state: "display"
    states: [
        State {
            name: "display"
            PropertyChanges {
                target: label
                visible: true
            }
            PropertyChanges {
                target: textField
                visible: false
            }
            PropertyChanges {
                target: textField
                visible: false
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: label
                visible: false
            }
            PropertyChanges {
                target: textField
                visible: true
            }
        }
    ]
}
