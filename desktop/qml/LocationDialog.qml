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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10

import io.croplan.components 1.0
import "date.js" as MDate

Dialog {
    id: dialog

    property alias name: nameField.text
    property int bedLength: Number(lengthField.text)
    property double bedWidth: Number.fromLocaleString(Qt.locale(), widthField.text)
    property int quantity: Number(quantityField.text)
    property alias greenhouse: greenhouseCheckBox.checked

    property string mode: "add"
    property var locationIdList: []
    property bool formAccepted: (!nameField.visible || nameField.acceptableInput)
                                && lengthField.acceptableInput
                                && widthField.acceptableInput
                                && (!quantityField.visible || quantityField.acceptableInput)

    readonly property var widgetField: [
        [nameField, "name", name],
        [lengthField, "bed_length", bedLength],
        [widthField, "bed_width", bedWidth],
        [greenhouseCheckBox, "greenhouse", greenhouse ? 1 : 0]
    ]

    function clearForm() {
        nameField.reset();
        lengthField.reset();
        widthField.reset();
        quantityField.reset();
        greenhouseCheckBox.checked = false;
        greenhouseCheckBox.manuallyModified = false;
    }

    function editedValues() {
        var map = {};

        for (var i in widgetField) {
            var widget = widgetField[i][0]
            var name = widgetField[i][1]
            var value = widgetField[i][2]

            if (widget.manuallyModified) {
                map[name] = value;
            }
        }
        return map;
    }

    // Set item to value only if it has not been manually modified by
    // the user. To do this, we use the manuallyModified boolean value.
    function setFieldValue(item, value) {
        if (!value || item.manuallyModified)
            return;

        if (item instanceof MyTextField)
            item.text = value;
        else if (item instanceof CheckBox || item instanceof ChoiceChip)
            item.checked = value;
        else if (item instanceof MyComboBox)
            item.setRowId(value);
    }

    function setFormValues(val) {
        setFieldValue(nameField, val['name']);
        setFieldValue(widthField, val['bed_width']);
        setFieldValue(lengthField, val['bed_length']);
        setFieldValue(greenhouseCheckBox, val['greenhouse'] === 1 ? true : false);
    }

    onAboutToShow: {
        clearForm();
        if (mode === "edit") {
            // TODO: there's probably a bottleneck here.
//            var idList = []
//            for (var i = 0; i < locationIdList.length; i++)
//                idList.push(locationModel.locationId(locationIdList[i]));
            var valueMap = Location.commonValues(locationIdList);
            setFormValues(valueMap);
        }

        if (nameField.visible)
            nameField.forceActiveFocus();
        else if (lengthField.visible)
            lengthField.forceActiveFocus()
    }

    title: mode === "add" ? qsTr("Add Locations") : qsTr("Edit Locations")
    focus: true

    footer: AddEditDialogFooter {
        //        height: childrenRect.height
        //        width: parent.width
        applyEnabled: dialog.formAccepted
        mode: dialog.mode
    }

    ColumnLayout {
        id: mainColumn
        spacing: Units.smallSpacing
        width: parent.width

        MyTextField {
            id: nameField
            visible: mode === "add" || !locationIdList || locationIdList.length === 1
            labelText: qsTr("Name")
            floatingLabel: true

            Layout.fillWidth: true

            Keys.onReturnPressed: if (formAccepted) dialog.accept();
            Keys.onEnterPressed: if (formAccepted) dialog.accept();
        }

        MyTextField {
            id: lengthField
            labelText: qsTr("Length")
            suffixText: qsTr("bed m")
            floatingLabel: true
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator {
                bottom: 0
                top: 999
            }

            Layout.fillWidth: true

            Keys.onReturnPressed: if (formAccepted) dialog.accept();
            Keys.onEnterPressed: if (formAccepted) dialog.accept();
        }

        MyTextField {
            id: widthField
            labelText: qsTr("Width")
            suffixText: qsTr("m")
            floatingLabel: true
            inputMethodHints: Qt.ImhDigitsOnly
            validator: QropDoubleValidator {
                bottom: 0
                top: 999
                decimals: 2
            }

            Layout.fillWidth: true

            Keys.onReturnPressed: if (formAccepted) dialog.accept();
            Keys.onEnterPressed: if (formAccepted) dialog.accept();
        }

        MyTextField {
            id: quantityField
            visible: mode === "add"
            text: "1"
            labelText: qsTr("Quantity")
            floatingLabel: true
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator {
                bottom: 1
                top: 999
            }

            Layout.fillWidth: true

            Keys.onReturnPressed: if (formAccepted) dialog.accept();
            Keys.onEnterPressed: if (formAccepted) dialog.accept();
        }

        CheckBox {
            id: greenhouseCheckBox
            property bool manuallyModified
            text: qsTr("Greenhouse")
            onPressed: manuallyModified = true
        }
    }
}
