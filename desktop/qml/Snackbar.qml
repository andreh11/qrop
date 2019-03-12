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

Popup {
    id: control

    property alias text: label.text
    property alias actionText: actionButton.text
    property int duration: 3000
    property int labelMargin: 16

    // Emitted when the user clicked on the action button.
    signal clicked()

    // Dimensions according to Material guidelines.
    implicitHeight: 48
    implicitWidth: Math.max(344, label.implicitWidth + labelMargin*2)
    padding: 0
    Material.elevation: 6
    closePolicy: Popup.NoAutoClose

    onOpened: timer.start()

    Timer {
        id: timer
        interval: control.duration
        running: false
        onTriggered: control.close()
    }

    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.87)
        radius: 4
    }

    Label {
        id: label
        color: "#ffffffde"
        anchors { left: parent.left; leftMargin: labelMargin;  verticalCenter: parent.verticalCenter }
        font { family: "Roboto Regular"; pixelSize: Units.fontSizeBodyAndButton }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
    }

    Button {
        id: actionButton
        flat: true
        text: ""
        visible: text
        anchors { right: parent.right; rightMargin: 8 }
        Material.foreground: Material.accent
        onClicked: {
            control.close();
            control.clicked();
        }
    }

    enter: Transition {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 150 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }

    }

    exit: Transition {
        // shrink_fade_out
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }
}
