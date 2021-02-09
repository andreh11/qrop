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
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0
import Qt.labs.platform 1.0 as Lab

import io.qrop.components 1.0

Dialog {
    id: root

    readonly property string cropName: cropNameField.text.trim()
    property alias color: colorPicker.color
    property int familyId: familyField.selectedId
    property bool acceptableForm: cropNameField.acceptableInput
                                  && (familyId >= 0 || alreadyAssignedFamilyId)
    property bool alreadyAssignedFamilyId: false

    function prefill(name) {
        cropNameField.text = name;
    }

    title: qsTr("Add New Crop")
    modal: false
    margins: 0

    onAboutToShow: {
//        familyModel.refresh();
        cropNameField.text = ""
        familyField.selectedId = -1;
        familyField.text = "";
        cropNameField.forceActiveFocus();
    }

    footer: AddDialogButtonBox {
        width: parent.width
        onAccepted: root.accept()
        onRejected: root.reject()
        acceptableInput: acceptableForm
    }

    ColumnLayout {
        Keys.onReturnPressed: if (acceptableForm) root.accept();
        Keys.onEscapePressed: root.reject()
        Keys.onBackPressed: root.reject() // especially necessary on Android
        anchors.fill: parent
        spacing: Units.mediumSpacing

        MyTextField {
            id: cropNameField
            labelText: qsTr("Crop")
            validator: RegExpValidator { regExp: /\w[\w -]*/ }
            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Keys.onReturnPressed: if (acceptableForm && !popup.opened) root.accept();
        }

        ComboTextField {
            id: familyField
            visible: !alreadyAssignedFamilyId
            labelText: qsTr("Family")
            textRole: function (model) { return model.family; }
            idRole: function (model) { return model.family_id; }
            showAddItem: false
            model: cppFamily.modelFamily()
//            model: FamilyModel {
//                id: familyModel
//            }
            Keys.onReturnPressed: if (acceptableForm && !popup.opened) root.accept();
            Keys.onEnterPressed: if (acceptableForm && !popup.opened) root.accept();
            Layout.minimumWidth: 150
            Layout.fillWidth: true
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
