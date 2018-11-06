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
import QtQuick.Controls.Material 2.2

Item {
    id: control

    property bool acceptableInput: true
    property alias acceptText: acceptButton.text
    property alias rejectText: rejectButton.text

    signal accept()
    signal reject()

    implicitHeight: childrenRect.height

    Button {
        id: acceptButton
        Material.foreground: Material.accent
        anchors.right: parent.right
        anchors.rightMargin: Units.smallSpacing
        flat: true
        text: qsTr("Add")
        enabled: acceptableInput
        onClicked: control.accept();
        Keys.onReturnPressed: clicked()
    }
    
    Button {
        id: rejectButton
        flat: true
        text: qsTr("Cancel")
        anchors.right: acceptButton.left
        onClicked: control.reject();
        Material.foreground: Material.accent
        Keys.onReturnPressed: clicked()
    }
    
}
