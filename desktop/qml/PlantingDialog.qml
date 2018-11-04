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

Dialog {
    id: dialog

    property var model
    property string mode: "add"
    property string plantingIds: ""
    property alias formAccepted: plantingForm.accepted
    property alias plantingForm: plantingForm

    signal plantingsAdded(int successions)

    function createPlanting() {
        plantingForm.clearAll();
        dialog.title = qsTr("Add planting(s)")
        dialog.open()
    }

    function editPlantings(plantingIds) {
        plantingForm.clearAll();
        dialog.title = qsTr("Edit planting(s)")
        dialog.open()
    }

    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    header: PlantingFormHeader {
        id: plantingFormHeader
        estimatedRevenue: plantingForm.estimatedRevenue
        estimatedYield: plantingForm.estimatedYield
        unitText: plantingForm.unitText

        onCropSelected: {
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.varietyField.popup.open()
        }

        onNewCropAdded: {
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.addVarietyDialog.open();
        }
    }

    footer: Item {
        width: parent.width
        height: childrenRect.height
        Button {
            id: cancelButton
            flat: true
            text: qsTr("Cancel")
            anchors.right: applyButton.left
            anchors.rightMargin: Units.smallSpacing
            onClicked: dialog.reject();
            Material.foreground: Material.accent
        }

        Button {
            id: applyButton
            Material.foreground: Material.accent
            anchors.right: parent.right
            anchors.rightMargin: Units.smallSpacing
            flat: true
            text: mode === "add" ? qsTr("Add") : qsTr("Edit")
            enabled: formAccepted
            onClicked: dialog.accept();
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        Keys.onUpPressed: verticalScrollBar.decrease()
        Keys.onDownPressed: verticalScrollBar.increase()

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollBar
            visible: largeDisplay
            parent: scrollView.parent
            anchors {
                top: scrollView.top
                left: scrollView.right
                leftMargin: 4
                bottom: scrollView.bottom
            }
        }

        PlantingForm {
            id: plantingForm
            anchors.fill: parent
            focus: true
            cropFieldIndex: plantingFormHeader.currentIndex
        }
    }

    onOpened: {
        plantingFormHeader.cropField.contentItem.forceActiveFocus();
        plantingFormHeader.cropField.popup.open();
    }

    onAccepted: {
        Planting.addSuccessions(plantingForm.successions,
                                plantingForm.weeksBetween,
                                plantingForm.values);
        dialog.plantingsAdded(plantingForm.successions)
        model.refresh();
    }
}
