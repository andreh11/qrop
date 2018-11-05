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

import io.croplan.components 1.0

Rectangle {
    id: control

    property int estimatedYield: 0
    property int estimatedRevenue: 0
    property string unitText: ""
    property alias currentIndex: cropField.currentIndex
    property alias cropField: cropField
    property int cropId: cropModel.rowId(cropField.currentIndex)

    signal newCropAdded(int newCropId)
    signal cropSelected()

    color: Material.color(Material.Grey, Material.Shade200)
    radius: 2
    clip: true
//    height: textIcon.height + 2 * Units.smallSpacing
    implicitHeight: 60
    width: parent.width

    CropModel {
        id: cropModel
    }

    RowLayout {
        id: rowLayout
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
            color: Material.color(Material.Green, Material.Shade400)

            Text {
                anchors.centerIn: parent
                text: cropField.currentText.slice(0,2)
                color: "white"
                font.family: "Roboto Regular"
                font.pixelSize: 24
            }
        }

        MyComboBox {
            id: cropField
            focus: true
            Layout.fillWidth: true
            model: cropModel
            textRole: "crop"
            editable: false
            showAddItem: true
            addItemText: qsTr("Add Crop")

            onActivated: control.cropSelected()
            onAddItemClicked: addCropDialog.open()

            AddCropDialog {
                id: addCropDialog
                width: parent.width
                onAccepted: {
                    Crop.add({"crop" : cropName,
                              "family_id" : familyId,
                               "color" : color});
                    cropModel.refresh();
                    cropField.currentIndex = cropField.find(cropName);
                    var newCropId = cropModel.rowId(cropField.currentIndex)
                    control.newCropAdded(newCropId)
                }
            }
        }
        
        ColumnLayout {
            Label {
                text: qsTr("Yield")
                Layout.alignment: Qt.AlignRight
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeCaption
                color: Qt.rgba(0,0,0, 0.50)
            }
            Label {
                id: estimatedYieldLabel
                text: "%L1 %2".arg(estimatedYield).arg(unitText)
                Layout.alignment: Qt.AlignRight
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                color: Qt.rgba(0,0,0, 0.87)
            }
        }
        
        ColumnLayout {
            Label {
                text: qsTr("Revenue")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeCaption
                color: Qt.rgba(0,0,0, 0.50)
                Layout.alignment: Qt.AlignRight
            }
            Label {
                id: estimatedRevenueLabel
                text: "%L1 €".arg(estimatedRevenue)
                horizontalAlignment: Text.AlignHCenter
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                color: Qt.rgba(0,0,0, 0.87)
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
