/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

import io.qrop.components 1.0

Rectangle {
    id: control

    property int estimatedYield: 0
    property int estimatedRevenue: 0
    property bool showYieldAndRevenue: true
    property bool showAddItem: true
    property bool bulkEditMode: false
    property string unitText: ""
    property alias cropField: cropField
    property alias cropId: cropField.selectedId
    property string mode

    signal cropSelected()

    function refresh() {
        cropModel.refresh();
    }

    function reset() {
        refresh();
        cropField.reset();
    }

    color: Material.color(Material.Grey, Material.Shade200)
    Material.elevation: 2
    radius: 2
    clip: true
    implicitHeight: Units.dialogHeaderHeight
    width: parent.width

    CropModel {
        id: cropModel
    }

    Label {
        visible: bulkEditMode
        anchors.centerIn: parent
        text: qsTr("Bulk edit")
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
    }

    RowLayout {
        id: rowLayout
        visible: !bulkEditMode
        anchors.fill: parent
        spacing: Units.mediumSpacing
        anchors {
            leftMargin: Units.mediumSpacing
            rightMargin: anchors.leftMargin
            topMargin: Units.smallSpacing
            bottomMargin: anchors.topMargin
        }

        Rectangle {
            id: textIcon
            Layout.alignment: Qt.AlignVCenter
            height: 40
            width: height
            radius: 80
            color: {
                if (cropId > 0) {
                    var map = Crop.mapFromId("crop", cropId);
                    return map['color'];
                } else {
                    return Material.color(Material.Grey, Material.Shade400);
                }
            }

            Text {
                anchors.centerIn: parent
                text: cropId > 0 ? cropField.text.slice(0,2) : ""
                color: "white"
                font { family: "Roboto Regular"; pixelSize: 24 }
            }
        }

        ComboTextField {
            id: cropField
            enabled: mode === "add"
            Layout.topMargin: Units.smallSpacing
            textRole: function (model) { return model.crop; }
            idRole: function (model) { return model.crop_id; }
            showAddItem: true
            addItemText: text ? qsTr('Add new crop "%1"').arg(text) : qsTr("Add new crop")
            hasError: selectedId < 0
            errorText: qsTr("Choose a crop")

            Layout.fillWidth: true
            model: cropModel

            onAddItemClicked: {
                addCropDialog.open()
                addCropDialog.prefill(text)
            }

            onSelectedIdChanged: if (selectedId > 0) cropSelected()

            AddCropDialog {
                id: addCropDialog

                // When creating a new crop, we have to wait for dialog to close in order
                // to not lose the focus. We use the newId property as a temporary variable
                // to be used in onClosed.
                property int newId: -1

                width: parent.width

                onRejected: {
                    cropField.text = "";
                    newId = -1
                }

                onAccepted: {
                    var id = Crop.add({"crop" : cropName,
                                       "family_id" : familyId,
                                       "color" : color});
                    cropModel.refresh();
                    cropField.text = cropName
                    newId = id
                }

                onClosed: cropField.selectedId = newId
            }
        }

        TitleLabel {
            id: estimatedYieldLabel
            visible: showYieldAndRevenue
            title: qsTr("Yield")
            text: "%L1 %2".arg(estimatedYield).arg(unitText)
        }
        
        TitleLabel {
            id: estimatedRevenueLabel
            visible: showYieldAndRevenue
            title: qsTr("Revenue")
            text: qsTr("$%L1").arg(estimatedRevenue)
        }
    }
}
