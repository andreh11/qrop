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

    property var model
    property string mode: "add"
    property alias formAccepted: plantingForm.accepted
    property alias plantingForm: plantingForm
    property alias currentYear: plantingForm.currentYear
    property var editPlantingIdList: []
    property var editPlantingValueMap

    signal plantingsAdded(int successions)
    signal plantingsModified(int successions)

    function refresh() {
        plantingFormHeader.reset();
        plantingFormHeader.bulkEditMode = false;
    }

    function createPlanting() {
        mode = "add";
        refresh();

        plantingForm.clearAll();
        dialog.open()
    }

    function editPlantings(plantingIds) {
        mode = "edit";
        refresh();
        plantingForm.clearAll();

        dialog.editPlantingIdList = plantingIds;
        if (Planting.sameCrop(plantingIds)) {
            plantingFormHeader.cropField.selectedId = Planting.cropId(plantingIds[0])
            plantingFormHeader.cropField.text = Planting.cropName(plantingIds[0])
        } else {
            plantingFormHeader.bulkEditMode = true
        }

        if (plantingIds.length > 1)
            plantingForm.bulkEditMode = true

        // TODO: there's probably a bottleneck here.
        editPlantingValueMap = Planting.commonValues(plantingIds);
        plantingForm.plantingIds = plantingIds
        plantingForm.setFormValues(editPlantingValueMap);

        dialog.open()
    }

    modal: true
    focus: true
    contentWidth: scrollView.implicitWidth
    contentHeight: scrollView.implicitHeight
    width: scrollView.implicitWidth
    closePolicy: Popup.CloseOnEscape
    Material.background: Material.color(Material.Grey, Material.Shade100)
    title: mode === "add" ? qsTr("Add planting(s)") : qsTr("Edit planting(s)")

    topPadding: 0
    bottomPadding: topPadding
    leftPadding: Units.mediumSpacing
    rightPadding: leftPadding

    Shortcut {
        sequences: ["Ctrl+Enter", "Ctrl+Return"]
        enabled: dialog.visible
        context: Qt.ApplicationShortcut
        onActivated: if (plantingForm.accepted) accept();
    }

    header: PlantingFormHeader {
        id: plantingFormHeader
        estimatedRevenue: plantingForm.estimatedRevenue
        mode: dialog.mode
        estimatedYield: plantingForm.estimatedYield
        unitText: plantingForm.unitText
        onCropSelected: if (mode === "add") plantingForm.varietyField.forceActiveFocus();
    }

    footer: AddEditDialogFooter {
        applyEnabled: plantingForm.accepted
        rejectToolTip: qsTr("You have to choose at least a variety to add a planting.")
        mode: dialog.mode
        width: parent.width
        height: 48
    }

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
        if (mode === "add")
            plantingFormHeader.cropField.forceActiveFocus();
        else
            plantingForm.varietyField.forceActiveFocus();
    }

    onAccepted: {
        if (mode === "add") {
            var idList = Planting.addSuccessions(plantingForm.successions,
                                                 plantingForm.weeksBetween,
                                                 plantingForm.values);
            if (!idList.length)
                return;

            if (idList.length === 1) {
                var plantingId = idList[0]
                for (var locationId in plantingForm.assignedLengthMap) {
                    var length = plantingForm.assignedLengthMap[locationId]
                    Location.addPlanting(plantingId, locationId, length)
                }
            }
            dialog.plantingsAdded(plantingForm.successions)
        } else {
            console.log("Edited values:");
            var values = plantingForm.editedValues()
            for (var key in values)
                console.log(key, values[key])

            if (dialog.editPlantingIdList.length === 1)
                Planting.update(dialog.editPlantingIdList[0],
                                plantingForm.editedValues(),
                                plantingForm.assignedLengthMap);
            else
                Planting.updateList(dialog.editPlantingIdList,
                                    plantingForm.editedValues(),
                                    plantingForm.assignedLengthMap);
            dialog.plantingsModified(dialog.editPlantingIdList.length);
        }

    }
}
