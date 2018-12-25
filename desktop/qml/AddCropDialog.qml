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
import QtCharts 2.0
import Qt.labs.platform 1.0 as Lab

import io.croplan.components 1.0
import "date.js" as MDate

Dialog {
    id: addCropDialog

    readonly property string cropName: cropNameField.text.trim()
    property alias color: colorPicker.color
    property int familyId: familyModel.rowId(familyField.currentIndex)
    property bool acceptableForm: cropNameField.acceptableInput && familyField.currentIndex >= 0

    title: qsTr("Add New Crop")
    standardButtons: Dialog.Ok | Dialog.Cancel

    onOpened: {
        cropNameField.text = ""
        familyField.currentIndex = -1
        cropNameField.forceActiveFocus();
    }

    footer: AddDialogButtonBox {
        width: parent.width
        onAccept: addCropDialog.accept()
        onReject: addCropDialog.reject()
        acceptableInput: acceptableForm
    }

    ColumnLayout {
        Keys.onReturnPressed: if (acceptableForm) addCropDialog.accept();
        Keys.onEscapePressed: addCropDialog.reject()
        Keys.onBackPressed: addCropDialog.reject() // especially necessary on Android
        anchors.fill: parent
        spacing: Units.mediumSpacing

        MyTextField {
            id: cropNameField
            labelText: qsTr("Crop")
            validator: RegExpValidator { regExp: /\w[\w ]*/ }
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm && !popup.opened) addCropDialog.accept();
        }

        MyComboBox {
            id: familyField
            labelText: qsTr("Family")
            Layout.minimumWidth: 150
            Layout.fillWidth: true
            editable: false
            model: FamilyModel {
                id: familyModel
            }
            textRole: "family"
            Keys.onReturnPressed: if (acceptableForm && !popup.opened) addCropDialog.accept();
        }

        ColumnLayout {
            Layout.fillWidth: true
            implicitHeight: contentHeight
            spacing: 4

            Label {
                text: qsTr("Color")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeCaption
                Material.foreground: Material.accent
            }

            ColorPicker {
                id: colorPicker
                Layout.fillWidth: true
                implicitWidth: parent.width
            }
        }
    }

}
