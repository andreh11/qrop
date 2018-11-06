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

    property alias varietyName: varietyNameField.text
    property int seedCompanyId: seedCompanyModel.rowId(seedCompanyField.currentIndex)

    title: qsTr("Add New Variety")
    standardButtons: Dialog.Ok | Dialog.Cancel

    onOpened: {
        varietyNameField.clear();
        seedCompanyField.currentIndex = 0;
        varietyNameField.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Units.mediumSpacing
        focus: true

        Keys.onReturnPressed: {
            if (varietyNameField.acceptableInput)
                control.accept();
        }
        Keys.onEscapePressed: control.reject()
        Keys.onBackPressed: control.reject() // especially necessary on Android

        MyTextField {
            id: varietyNameField
            width: parent.width
            validator: RegExpValidator { regExp: /[A-Za-z]+[A-Za-z0-9 ]*/ }

            labelText: qsTr("Variety")
            Layout.fillWidth: true
            Layout.minimumWidth: 100

            Keys.onReturnPressed: {
                if (varietyNameField.acceptableInput)
                    control.accept();
            }
            Keys.onEscapePressed: control.reject()
            Keys.onBackPressed: control.reject() // especially necessary on Android
        }

        MyComboBox {
            id: seedCompanyField
            labelText: qsTr("Seed Company")
            Layout.minimumWidth: 150
            Layout.fillWidth: true
            editable: false
            model: SeedCompanyModel {
                id: seedCompanyModel
            }
            textRole: "seed_company"
        }
    }
}
