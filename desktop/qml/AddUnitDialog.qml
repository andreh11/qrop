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

import io.qrop.components 1.0

Dialog {
    id: control

    property alias unitName: unitNameField.text
    property alias unitAbbreviation: abbreviationField.text
    readonly property bool acceptableForm: unitNameField.acceptableInput && abbreviationField.acceptableInput

    function prefill(text) {
        abbreviationField.text = text;
    }

    title: qsTr("Add Unit")
    margins: 0

    onAboutToShow: {
        unitNameField.clear();
        abbreviationField.clear();
    }

    onOpened: abbreviationField.forceActiveFocus();

    footer: AddDialogButtonBox {
        width: parent.width
        onAccepted: control.accept()
        onRejected: control.reject()
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
            id: abbreviationField
            width: parent.width
            validator: RegExpValidator { regExp: /\w[\w -]*/ }

            labelText: qsTr("Abbreviation")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm) control.accept();
        }

        MyTextField {
            id: unitNameField
            width: parent.width
            validator: RegExpValidator { regExp: /\w[\w -]*/ }

            labelText: qsTr("Full name")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm) control.accept();
        }
    }
}
