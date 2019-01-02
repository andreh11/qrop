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
import Qt.labs.settings 1.0

import io.croplan.components 1.0

Page {
    id: page

    property int paneWidth: 600
    property bool showFamilyPane: false
    property bool showSeedCompanyPane: false
    property bool showUnitPane: false
    property bool showTaskTypePane: false

    title: qsTr("Settings")
    Material.background: Material.color(Material.Grey, Material.Shade100)

    Settings {
        id: settings
        property alias farmName: farmNameField.text
        property string dateType
    }

    Column {
        width: paneWidth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        spacing: Units.smallSpacing
        topPadding: Units.smallSpacing
        bottomPadding: topPadding

        Pane {
            width: parent.width
            Material.elevation: 2
            Material.background: "white"
            padding: 0

            ColumnLayout {
                width: parent.width
                spacing: 0

                RowLayout {
                    Layout.minimumHeight: Units.rowHeight
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        text: qsTr("Farm name")
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        Layout.fillWidth: true
                    }

                    TextInput {
                        id: farmNameField
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        Layout.minimumWidth: 200
                    }

                }

                ThinDivider { width: parent.width }

                RowLayout {
                    width: parent.width
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Date type")
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    ComboBox {
                        Material.elevation: 0
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        Layout.minimumWidth: 200
                        currentIndex: settings.dateType == "week" ? 0 : 1
                        model: [qsTr("Week"), qsTr("Full")]
                        onCurrentTextChanged: {
                            if (currentIndex == 0)
                                settings.dateType = "week"
                            else
                                settings.dateType = "date"
                        }
                    }
                }

            Item { Layout.fillHeight: true }
            }

        }

        Pane {
            width: parent.width
            Material.elevation: 2
            Material.background: "white"
            padding: 0

            ColumnLayout {
                width: parent.width
                spacing: 0

                ThinDivider { width: parent.width }

                RowLayout {
                    width: parent.width
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        Layout.fillWidth: true
                        text: "Families, crops and varieties"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    RoundButton {
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        flat: true
                        onClicked: showFamilyPane = true
                    }
                }

                ThinDivider { width: parent.width }

                RowLayout {
                    width: parent.width
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        Layout.fillWidth: true
                        text: "Seed companies"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    RoundButton {
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        flat: true
                        //                        onClicked: showFamilyPane = true
                    }
                }

                ThinDivider { width: parent.width }

                RowLayout {
                    width: parent.width
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        Layout.fillWidth: true
                        text: "Task types"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    RoundButton {
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        flat: true
                        //                        onClicked: showFamilyPane = true
                    }
                }

                ThinDivider { width: parent.width }

                RowLayout {
                    width: parent.width
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.rightMargin: Layout.leftMargin

                    Label {
                        Layout.fillWidth: true
                        text: "Units"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
                    }

                    RoundButton {
                        text: "\ue315"
                        font.family: "Material Icons"
                        font.pixelSize: 22
                        flat: true
                        //                        onClicked: showFamilyPane = true
                    }
                }

                ThinDivider { width: parent.width }

                Item { Layout.fillHeight: true }

            }
        }
    }

    SettingsFamilyPane {
        id: familyPane
        height: parent.height
        width: paneWidth
        visible: showFamilyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showFamilyPane = false
    }

    //        ListView {
    //            id: cropListView
    //            clip: true
    //            spacing: Units.smallSpacing
    //            anchors {
    //                top: rowLayout.bottom
    //                topMargin: Units.mediumSpacing
    //                left: parent.left
    //                right: parent.right
    //                bottom: parent.bottom
    //            }

    //            model: CropModel {
    //                id: cropModel
    //                sortColumn: "family_id"
    //            }

    //            section.property: "family_id"
    //            section.delegate: Rectangle {
    //                id: sectionDelegate
    //                color: Material.color(Material.Grey, Material.Shade200)
    //                height: headerRow.height
    //                width: parent.width

    //                MouseArea {
    //                    id: sectionMouseArea
    //                    anchors.fill: parent
    //                    hoverEnabled: true

    //                    Row {
    //                        id: headerRow
    //                        width: parent.width
    //                        height: Units.rowHeight
    //                        spacing: Units.formSpacing
    //                        leftPadding: Units.mediumSpacing

    //                        TextCheckBox {
    //                            id: headerCheckbox
    //                            text: Family.name(section)
    //                            selectionMode: false
    //                            anchors.verticalCenter: headerRow.verticalCenter
    //                            color: Family.color(section)
    //                            //                                width: 24
    //                            width: Units.rowHeight * 0.8
    //                            round: true
    //                            //                                color:
    //                            //                                checked: model.planting_id in selectedIds && selectedIds[model.planting_id]

    //                            MouseArea {
    //                                anchors.fill: parent
    //                            }
    //                        }

    //                        TextInput {
    //                            text: Family.name(section)
    //                            font.family: "Roboto Regular"
    //                            font.pixelSize: Units.fontSizeBodyAndButton
    //                            anchors.verticalCenter: parent.verticalCenter
    //                            width: 200
    //                            onEditingFinished: {
    //                                Family.update(section, {"family": text})
    //                                cropModel.refresh();
    //                            }

    //                        }

    //                        ComboBox {
    //                            flat: true
    //                            model: 10
    //                            width: 200
    //                            currentIndex: Family.interval(section)
    //                            font.family: "Roboto Regular"
    //                            font.pixelSize: Units.fontSizeBodyAndButton
    //                            displayText: qsTr("%L1 years", "", currentIndex).arg(currentIndex)
    //                            onCurrentIndexChanged: Family.update(section, {"interval": currentIndex})
    //                            anchors.verticalCenter: parent.verticalCenter

    //                            ToolTip.text: qsTr("Minimum rotation interval for %1").arg(Family.name(section))
    //                            ToolTip.visible: hovered
    //                            ToolTip.delay: 200
    //                        }
    //                    }
    //                }
    //            }

    //            delegate: Rectangle {
    //                id: delegate
    //                height: column.height
    //                width: parent.width
    //                border.color: Material.color(Material.Grey, Material.Shade400)
    //                border.width: mouseArea.containsMouse ? 1 : 0

    //                MouseArea {
    //                    id: mouseArea
    //                    anchors.fill: parent
    //                    hoverEnabled: true

    //                    Column {
    //                        id: column
    //                        width: parent.width
    //                        anchors.verticalCenter: parent.verticalCenter

    //                        RowLayout {
    //                            id: row
    //                            height: Units.rowHeight
    //                            width: parent.width
    //                            spacing: Units.formSpacing
    //                            Layout.alignment: Qt.AlignTop

    //                            TextCheckBox {
    //                                id: checkBox
    //                                text: model.crop
    //                                selectionMode: false
    //                                Layout.leftMargin: Units.mediumSpacing
    //                                //                                width: 24
    //                                Layout.preferredWidth: Units.rowHeight * 0.8
    //                                round: true
    //                                color: model.color
    //                                //                                checked: model.planting_id in selectedIds && selectedIds[model.planting_id]
    //                            }

    //                            TextInput {
    //                                text: model.crop
    //                                font.family: "Roboto Regular"
    //                                Layout.minimumWidth: 200
    //                                Layout.fillWidth: true
    //                                onEditingFinished: {
    //                                    Crop.update(model.crop_id, {"crop": text});
    //                                    cropModel.refresh();
    //                                }
    //                            }

    //                            MyToolButton {
    //                                visible: mouseArea.containsMouse
    //                                text: enabled ? "\ue872" : ""
    //                                font.family: "Material Icons"
    //                                font.pixelSize: 22
    //                                ToolTip.text: qsTr("Remove crop")
    //                                ToolTip.visible: hovered
    //                                ToolTip.delay: 200

    //                                onClicked: confirmCropDeleteDialog.open()

    //                                Dialog {
    //                                    id: confirmCropDeleteDialog
    //                                    title: qsTr("Delete %1?").arg(model.crop)
    //                                    standardButtons: Dialog.Ok | Dialog.Cancel

    //                                    Text {
    //                                        width: parent.width
    //                                        wrapMode: Text.WordWrap
    //                                        text: qsTr("All plantings will be lost.")
    //                                    }

    //                                    onAccepted: {
    //                                        Crop.remove(model.crop_id)
    //                                        cropModel.refresh();
    //                                    }

    //                                    onRejected: confirmCropDeleteDialog.close()
    //                                }
    //                            }

    //                            MyToolButton {
    //                                id: varietyButton
    //                                visible: mouseArea.containsMouse || checked
    //                                Layout.leftMargin: -28
    //                                Layout.rightMargin: Units.mediumSpacing
    //                                checkable: true
    //                                text: checked ?  "\ue313" : "\ue315"
    //                                font.family: "Material Icons"
    //                                font.pixelSize: 22
    //                                //                            enabled: model.task_type_id > 3
    //                                //                            onClicked: {
    //                                //                                Task.remove(model.task_id);
    //                                //                                page.refresh();
    //                                //                            }
    //                                ToolTip.text: checked ? qsTr("Hide varieties") : qsTr("Show varieties")
    //                                ToolTip.visible: hovered
    //                                ToolTip.delay: 200
    //                            }
    //                        }

    //                        ListView {
    //                            id: varietyView
    //                            visible: varietyButton.checked
    //                            width: parent.width
    //                            height: contentHeight
    //                            model: VarietyModel {
    //                                id: varietyModel
    //                                cropId:  model.crop_id
    //                            }

    //                            delegate: Rectangle {
    //                                id: varietyDelegate
    //                                height: varietyColumn.height
    //                                width: parent.width

    //                                MouseArea {
    //                                    id: varietyMouseArea
    //                                    anchors.fill: parent
    //                                    hoverEnabled: true

    //                                    Column {
    //                                        id: varietyColumn
    //                                        width: parent.width

    //                                        RowLayout {
    //                                            id: varietyRow
    //                                            height: Units.rowHeight
    //                                            width: parent.width
    //                                            spacing: Units.formSpacing

    //                                            TextInput {
    //                                                text: model.variety
    //                                                color: Qt.rgba(0, 0, 0, 0.7)
    //                                                font.family: "Roboto Regular"
    //                                                Layout.leftMargin: Units.mediumSpacing + Units.formSpacing + Units.rowHeight * 0.8
    //                                                Layout.minimumWidth: 200

    //                                                onEditingFinished: Variety.update(model.variety_id,
    //                                                                                  {"variety": text})
    //                                            }

    //                                            ComboBox {
    //                                                flat: true
    //                                                Layout.minimumWidth: 200
    //                                                model: SeedCompanyModel {
    //                                                }
    //                                                textRole: "seed_company"

    //                                            }

    //                                            Item { Layout.fillWidth:  true }

    //                                            MyToolButton {
    //                                                height: parent.height * 0.8
    //                                                visible: varietyMouseArea.containsMouse
    //                                                text: enabled ? "\ue872" : ""
    //                                                font.family: "Material Icons"
    //                                                font.pixelSize: 22
    //                                                //                            enabled: model.task_type_id > 3
    //                                                //                            onClicked: {
    //                                                //                                Task.remove(model.task_id);
    //                                                //                                page.refresh();
    //                                                //                            }
    //                                                ToolTip.text: qsTr("Remove variety")
    //                                                ToolTip.visible: hovered
    //                                                ToolTip.delay: 200

    //                                                onClicked: confirmVarietyDeleteDialog.open()

    //                                                Dialog {
    //                                                    id: confirmVarietyDeleteDialog
    //                                                    title: qsTr("Delete %1?").arg(model.variety)
    //                                                    standardButtons: Dialog.Ok | Dialog.Cancel

    //                                                    Text {
    //                                                        width: parent.width
    //                                                        wrapMode: Text.WordWrap
    //                                                        text: qsTr("All plantings will be lost.")
    //                                                    }

    //                                                    onAccepted: {
    //                                                        Variety.remove(model.variety_id)
    //                                                        varietyModel.refresh();
    //                                                    }

    //                                                    onRejected: confirmVarietyDeleteDialog.close()
    //                                                }
    //                                            }

    //                                            MyToolButton {
    //                                                enabled: false
    //                                                visible: varietyMouseArea.containsMouse
    //                                                Layout.leftMargin: -28
    //                                                Layout.rightMargin: Units.mediumSpacing
    //                                                checkable: true
    //                                                text: ""
    //                                                font.family: "Material Icons"
    //                                                font.pixelSize: 22
    //                                                //                            enabled: model.task_type_id > 3
    //                                                //                            onClicked: {
    //                                                //                                Task.remove(model.task_id);
    //                                                //                                page.refresh();
    //                                                //                            }
    //                                                ToolTip.text: checked ? qsTr("Hide varieties") : qsTr("Show varieties")
    //                                                ToolTip.visible: hovered
    //                                                ToolTip.delay: 200
    //                                            }
    //                                        }

    //                                    }
    //                                }
    //                            }
    //                        }

    //                        Button {
    //                            id: addVarietyButton
    //                            visible: varietyButton.checked
    //                            anchors.right: parent.right
    //                            anchors.rightMargin: Units.mediumSpacing
    //                            flat: true
    //                            text: qsTr("Add variety")
    //                            onClicked: addVarietyDialog.open();

    //                            AddVarietyDialog {
    //                                id: addVarietyDialog
    //                                onAccepted: {
    //                                    if (seedCompanyId > 0)
    //                                        Variety.add({"variety" : varietyName,
    //                                                        "crop_id" : model.crop_id,
    //                                                        "seed_company_id" : seedCompanyId});
    //                                    else
    //                                        Variety.add({"variety" : varietyName,
    //                                                        "crop_id" : model.crop_id});

    //                                    varietyModel.refresh();
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }

}
