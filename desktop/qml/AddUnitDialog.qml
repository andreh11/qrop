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

import io.croplan.components 1.0
import "date.js" as MDate

Dialog {
    id: control

    property alias unitName: unitNameField.text
    property alias unitAbbreviation: abbreviationField.text
    readonly property bool acceptableForm: unitNameField.acceptableInput && abbreviationField.acceptableInput

    title: qsTr("Add Unit")
    standardButtons: Dialog.Ok | Dialog.Cancel
    margins: 0

    onOpened: {
        unitNameField.clear();
        abbreviationField.clear();
        unitNameField.forceActiveFocus();
    }

    footer: AddDialogButtonBox {
        width: parent.width
        onAccept: control.accept()
        onReject: control.reject()
        acceptableInput: acceptableForm
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Units.mediumSpacing

        Keys.onReturnPressed: {
            if (unitNameField.text)
                control.accept();
        }
        Keys.onEscapePressed: control.reject()
        Keys.onBackPressed: control.reject() // especially necessary on Android

        MyTextField {
            id: unitNameField
            width: parent.width
            validator: RegExpValidator { regExp: /\w[\w -]*/ }

            labelText: qsTr("Full name")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm) control.accept();
        }

        MyTextField {
            id: abbreviationField
            width: parent.width
            validator: RegExpValidator { regExp: /\w[\w -]*/ }

            labelText: qsTr("Abbreviation")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm) control.accept();
        }

    }
}
