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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.qrop.components 1.0

ToolButton {
    id: control

    property int year
    property var conflictList
    property int actionPlantingId: -1
    property int otherPlantingId: -1
    property int locationId

    signal plantingModified
    signal plantingRemoved

    onConflictListChanged: {
        // Build a new ListModel.
        if (lmodel.count)
            lmodel.clear();
        for (var key in conflictList) {
            lmodel.append({"id1": Number(key), "id2": Number(conflictList[key])})
        }
    }

    visible: lmodel.count
    opacity: visible ? 1 : 0
    text: "\ue8e9"
    font.pixelSize: Units.fontSizeTitle
    font.family: "Material Icons"
    Material.foreground: Material.color(Material.Red)
    onClicked: conflictMenu.open()

    ListModel {
        id: lmodel
    }

    Menu {
        id: conflictMenu
        focus: true
        y: parent.height * 2/3
        height: Math.min(300, conflictStackView.contentHeight + padding)
        width: conflictStackView.width
        margins: 0 // Ensure visibility on screen border.

        onClosed: conflictStackView.replace(conflictView)

        StackView {
            id: conflictStackView
            width: currentItem.implicitWidth
            height: currentItem.implicitHeight
            initialItem: conflictView

            // We don't want transitions in a menu popup.
            pushEnter: null
            pushExit: null
            popEnter: null
            popExit: null

        }
    }

    Component {
        id: plantingForm
        LightPlantingForm {
            plantingId: actionPlantingId
            year: control.year
            onPlantingModified: control.plantingModified()
            onCancel: conflictStackView.pop()
            onDone: conflictMenu.close()
        }
    }

    Component {
        id: conflictView
        ListView {
            implicitWidth: 280
//            width: 250
//            width: parent.width
            implicitHeight: Math.min(300, contentHeight)
            model: lmodel
            delegate: RowLayout {
                width: parent.width
                MenuItemDelegate {
                    text: Planting.cropName(id1)
                    Layout.fillWidth: true
                    Material.foreground: Material.primary
                    onClicked: {
                        actionPlantingId = id1
                        otherPlantingId = id2
                        conflictStackView.push(plantingActions)
                    }
                }

                MenuItemDelegate {
                    text: Planting.cropName(id2)
                    Layout.fillWidth: true
                    onClicked: {
                        actionPlantingId = id2
                        otherPlantingId = id1
                        conflictStackView.push(plantingActions)
                    }
                }
            }
        }
    }

    Component {
        id: plantingActions
        ColumnLayout {
            spacing: 0
            implicitWidth: 150

            RowLayout {
                ToolButton {
                    id: backButton
                    text: "\ue5c4" // arrow_back
                    font.family: "Material Icons"
                    font.pixelSize: Units.fontSizeHeadline
                    onClicked: conflictStackView.pop();
                }

                Label {
                    text: Planting.cropName(actionPlantingId)
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ThinDivider { Layout.fillWidth: true }

            MenuItemDelegate {
                text: qsTr("Edit")
                Layout.fillWidth: true
                onClicked: {
                    conflictStackView.push(plantingForm);
                }
            }

            MenuItemDelegate {
                text: qsTr("Unassign")
                Layout.fillWidth: true
                onClicked: {
                    Location.removePlanting(actionPlantingId, locationId);
                    plantingRemoved();
                    conflictMenu.close();
                }
            }

            MenuItemDelegate {
                text: qsTr("Split")
                Layout.fillWidth: true
                onClicked: {
                    Location.splitPlanting(actionPlantingId, otherPlantingId, locationId)
                    plantingRemoved();
                    conflictMenu.close()
                }
            }
        }
    }

}
