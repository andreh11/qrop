/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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

DialogButtonBox {
    id: control

    property alias applyEnabled: applyButton.enabled
    property alias keepOpened: keepOpenedCB.checked
    property string mode: "add"
    property string rejectToolTip: ""

    signal leftButtonClicked()

    function apply() {
        applyButton.clicked();
    }

    CheckBox {
        id: keepOpenedCB
        text: qsTr("Do not close")
        checked: false
        visible: mode == "add"
        DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
    }

    Button {
        id: rejectButton
        flat: true
        text: qsTr("Cancel")
        Material.foreground: Material.accent
        DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
    }
    
    Button {
        id: applyButton
        Material.background: Material.accent
        Material.foreground: "white"
        text: mode === "add" ? qsTr("Add") : qsTr("Edit")

        DialogButtonBox.buttonRole: (mode == "edit" || !keepOpened)
                                    ? DialogButtonBox.AcceptRole
                                    : DialogButtonBox.ApplyRole

        ToolTip.text: control.rejectToolTip
        ToolTip.visible: ToolTip.text && hovered && !enabled
    }
}
