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
    property alias currentYear: plantingForm.currentYear
    property var editPlantingIdList: []
    property var editPlantingValueMap

    signal plantingsAdded(int successions)
    signal plantingsModified(int successions)

    function createPlanting() {
        mode = "add";
        refresh();
        plantingForm.clearAll();
        dialog.title = qsTr("Add planting(s)")
        dialog.open()
    }

    function editPlantings(plantingIds) {
        mode = "edit";
        dialog.editPlantingIdList = plantingIds;
        refresh();
        plantingForm.clearAll();

        // TODO: there's probably a bottleneck here.
        editPlantingValueMap = Planting.commonValues(plantingIds);
        plantingForm.setFormValues(editPlantingValueMap);
        dialog.title = qsTr("Edit planting(s)")

        if (plantingIds.length === 1) {
            plantingFormHeader.cropField.setRowId(Planting.cropId(plantingIds[0]))
        }
        dialog.open()
    }

    function refresh() {
        plantingFormHeader.refresh();
    }

    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose
    Material.background: Material.color(Material.Grey, Material.Shade100)
    contentWidth: scrollView.implicitWidth
    contentHeight: scrollView.implicitHeight

    header: PlantingFormHeader {
        visible: mode === "add"
        id: plantingFormHeader
        estimatedRevenue: plantingForm.estimatedRevenue
        mode: dialog.mode
        estimatedYield: plantingForm.estimatedYield
        unitText: plantingForm.unitText

        onCropSelected: {
            plantingForm.cropId = cropId;
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.varietyField.popup.open();
        }

        onNewCropAdded: {
            plantingForm.cropId = newCropId;
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.addVarietyDialog.open();
        }
    }

    footer: AddEditDialogFooter {
        applyEnabled: plantingForm.accepted
        rejectToolTip: qsTr("You have to choose at least a variety to add a planting.")
        mode: dialog.mode
    }

    width: scrollView.implicitWidth

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        implicitWidth: plantingForm.chooseLocationMode ? plantingForm.locationViewWidth : 600

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
            mode: dialog.mode
            cropId: plantingFormHeader.cropId
        }
    }

    onOpened: {
        if (mode === "add") {
            plantingFormHeader.cropField.contentItem.forceActiveFocus();
            plantingFormHeader.cropField.popup.open();
        }
    }

    onAccepted: {
        if (mode === "add") {
            var idList = Planting.addSuccessions(plantingForm.successions,
                                                 plantingForm.weeksBetween,
                                                 plantingForm.values);
            if (!idList.length)
                return;

            dialog.plantingsAdded(plantingForm.successions)

            if (idList.length === 1) {
                var plantingId = idList[0]
                for (var locationId in plantingForm.assignedLengthMap) {
                    var length = plantingForm.assignedLengthMap[locationId]
                    Location.addPlanting(plantingId, locationId, length)
                }
            }
        } else {
            console.log("Edited values:");
            var values = plantingForm.editedValues()
            for (var key in values)
                console.log(key, values[key])
            Planting.updateList(dialog.editPlantingIdList, plantingForm.editedValues());
            dialog.plantingsModified(dialog.editPlantingIdList.length);
        }

    }

    Behavior on width { NumberAnimation { duration: 100 } }
    Behavior on height { NumberAnimation { duration: 100 } }
}
