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

    property int estimatedYield
    property int estimatedRevenue
    property string unitText
    property alias currentIndex: cropField.currentIndex

    color: Material.color(Material.Grey, Material.Shade200)
    radius: 2
    clip: true
    height: textIcon.height + 2 * Units.smallSpacing
    width: parent.width

    CropModel {
        id: cropModel
    }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: Units.mediumSpacing
        anchors.leftMargin: Units.mediumSpacing
        anchors.rightMargin: anchors.leftMargin
        anchors.topMargin: Units.smallSpacing
        anchors.bottomMargin: anchors.topMargin
        
        Rectangle {
            id: textIcon
            //                Layout.verticalCenter: parent.verticalCenter
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
            
            //                onAddItemClicked: addCropDialog.open()
            //                onCurrentIndexChanged: varietyField.currentIndex = 0
            //                onActivated: {
            //                    varietyField.forceActiveFocus()
            //                    varietyField.popup.open();
            //                }
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
