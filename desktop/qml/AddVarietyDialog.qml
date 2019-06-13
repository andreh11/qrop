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
    id: dialog

    readonly property string varietyName: varietyNameField.text.trim()
    property int seedCompanyId: seedCompanyField.selectedId
    property bool acceptableForm: varietyNameField.acceptableInput && seedCompanyId > 0
    property alias seedCompanyModel: seedCompanyModel

    function prefill(name) {
        varietyNameField.text = name
        var defaultSeedCompanyId = SeedCompany.defaultSeedCompany(cropId);
        if (defaultSeedCompanyId > 0) {
            seedCompanyField.setSelectedId(defaultSeedCompanyId);
            seedCompanyField.text = SeedCompany.name(defaultSeedCompanyId)
        }
    }

    title: qsTr("Add New Variety")
    modal: false

    onAboutToShow: {
        varietyNameField.clear();
        seedCompanyField.selectedId = -1
        seedCompanyField.text = "";
        varietyNameField.forceActiveFocus();
    }

    footer: AddDialogButtonBox {
        width: parent.width
        onAccepted: dialog.accept()
        onRejected: dialog.reject()
        acceptableInput: acceptableForm
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Units.smallSpacing
        focus: true

        Keys.onReturnPressed: if (acceptableForm) dialog.accept();
        Keys.onEnterPressed: if (acceptableForm) dialog.accept();

        Keys.onEscapePressed: dialog.reject()
        Keys.onBackPressed: dialog.reject() // especially necessary on Android

        MyTextField {
            id: varietyNameField
            width: parent.width
            validator: RegExpValidator { regExp: /\w[\w\d() ]*/ }

            labelText: qsTr("Variety")
            Layout.fillWidth: true
            Layout.minimumWidth: 100
        }

        ComboTextField {
            id: seedCompanyField
            Layout.topMargin: Units.mediumSpacing
            textRole: function (model) { return model.seed_company; }
            idRole: function (model) { return model.seed_company_id; }
            showAddItem: false
            hasError: selectedId < 0
            errorText: qsTr("Choose a company")
            labelText: qsTr("Seed Company")
            Layout.minimumWidth: 150
            Layout.fillWidth: true
            model: SeedCompanyModel { id: seedCompanyModel }

            Keys.onReturnPressed: if (acceptableForm) dialog.accept();
            Keys.onEnterPressed: if (acceptableForm) dialog.accept();
        }
    }
}
