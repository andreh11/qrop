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

import io.qrop.components 1.0

// TODO: refactor
Page {
    id: page

    property int paneWidth: 600
    property bool showFamilyPane: false
    property bool showKeywordPane: false
    property bool showSeedCompanyPane: false
    property bool showUnitPane: false
    property bool showTaskTypePane: false

    title: qsTr("Settings")
    Material.background: Material.color(Material.Grey, Material.Shade100)

    Settings {
        id: settings
        property alias farmName: farmNameField.text
        property alias showSeedCompanyBesideVariety: showSeedCompanySwitch.checked
        property alias useStandardBedLength: standardBedLengthSwitch.checked
        property alias standardBedLength: standardBedLengthField.text
        property string dateType
    }

    Settings {
        id: plantingSettings
        category: "PlantingsPane"
        property alias durationsByDefault: durationsByDefaultSwitch.checked
        property alias showDurationFields: showDurationFieldSwitch.checked
    }

    Settings {
        id: locationSettings
        category: "LocationView"
        property alias showFullName: showFullNameSwitch.checked
        property alias allowPlantingsConflict: allowPlantingsConflictSwitch.checked
    }

    Settings {
        id: harvestSettings
        category: "Harvest"
        property alias showAllPlantingIfNoneInWindow: showAllPlantingIfNoneInWindonSwitch.checked
    }

    Snackbar {
        id: restartSnackbar

        property int successions: 0

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Recent the application for modifications to take effect")
        visible: false
    }

    ScrollView {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: mainColumn.implicitWidth

        visible: !showFamilyPane && !showKeywordPane && !showSeedCompanyPane && !showUnitPane
                 && !showTaskTypePane
        contentHeight: mainColumn.implicitHeight

        Column {
            id: mainColumn
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.top: parent.top
//            anchors.bottom: parent.bottom

            spacing: Units.smallSpacing
            topPadding: Units.smallSpacing
            bottomPadding: topPadding

            Label {
                text: qsTr("General Settings")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
            }

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

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Show seed company beside variety names")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton

                        }

                        Switch {
                            id: showSeedCompanySwitch
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Standard bed length")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton

                        }

                        Switch {
                            id: standardBedLengthSwitch
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        enabled: standardBedLengthSwitch.checked
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin
                        Layout.minimumHeight: Units.rowHeight

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Bed length")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton

                        }

                        TextInput {
                            id: standardBedLengthField
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: IntValidator { bottom: 0; top: 999 }
                            Layout.minimumWidth: 200
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

            }

            Label {
                text: qsTr("Plantings view")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
            }

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
                            text: qsTr("Compute from durations by default")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.fillWidth: true
                        }

                        Switch {
                            id: durationsByDefaultSwitch
                            checked: true
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        Layout.minimumHeight: Units.rowHeight
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            text: qsTr("Show duration fields")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.fillWidth: true
                        }


                        Switch {
                            id: showDurationFieldSwitch
                            checked: true
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }
                }
            }

            Label {
                text: qsTr("Field map")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
            }

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
                            text: qsTr("Show complete name of locations")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.fillWidth: true
                        }

                        Switch {
                            id: showFullNameSwitch
                            checked: true
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        Layout.minimumHeight: Units.rowHeight
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            text: qsTr("Allow plantings conflicts on same location")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.fillWidth: true
                        }

                        Switch {
                            id: allowPlantingsConflictSwitch
                            checked: true
                            onToggled: restartSnackbar.open();
                        }
                    }

                    ThinDivider { width: parent.width }
                }
            }

            Label {
                text: qsTr("Harvests")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
            }

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
                            text: qsTr("Show all plantings if there is none in harvest window")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.fillWidth: true
                        }

                        Switch {
                            id: showAllPlantingIfNoneInWindonSwitch
                            checked: true
                            onToggled: restartSnackbar.open();
                        }
                    }
                }
            }

            Label {
                text: qsTr("Lists")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
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
                            text: qsTr("Families, crops and varieties")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            MouseArea {
                                anchors.fill: parent
                                onClicked: showFamilyPane = true
                            }
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
                            text: qsTr("Keywords")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            MouseArea {
                                anchors.fill: parent
                                onClicked: showKeywordPane = true
                            }
                        }

                        RoundButton {
                            text: "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            flat: true
                            onClicked: showKeywordPane = true
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Seed companies")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            MouseArea {
                                anchors.fill: parent
                                onClicked: showSeedCompanyPane = true
                            }
                        }

                        RoundButton {
                            text: "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            flat: true
                            onClicked: showSeedCompanyPane = true
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Task types")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            MouseArea {
                                anchors.fill: parent
                                onClicked: showTaskTypePane = true
                            }
                        }

                        RoundButton {
                            text: "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            flat: true
                            onClicked: showTaskTypePane = true
                        }
                    }

                    ThinDivider { width: parent.width }

                    RowLayout {
                        width: parent.width
                        Layout.leftMargin: Units.mediumSpacing
                        Layout.rightMargin: Layout.leftMargin

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Units")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            MouseArea {
                                anchors.fill: parent
                                onClicked: showUnitPane = true
                            }
                        }

                        RoundButton {
                            text: "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            flat: true
                            onClicked: showUnitPane = true
                        }
                    }

                    ThinDivider { width: parent.width }

                    Item { Layout.fillHeight: true }

                }
            }

            Label {
                text: qsTr("Development options")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                topPadding: Units.mediumSpacing
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

                        Button {
                            flat: true
                            text: qsTr("Reset database and quit")
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            onClicked: {
                                Database.resetDatabase();
                                Qt.quit();
                            }
                        }

                    }

                    ThinDivider { width: parent.width }
                    Item { Layout.fillHeight: true }
                }
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

    SettingsKeywordPane {
        id: keywordPane
        height: parent.height
        width: paneWidth
        visible: showKeywordPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showKeywordPane = false
    }


    SettingsSeedCompanyPane {
        id: seedCompanyPane
        height: parent.height
        width: paneWidth
        visible: showSeedCompanyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showSeedCompanyPane = false
    }

    SettingsUnitPane {
        id: unitPane
        height: parent.height
        width: paneWidth
        visible: showUnitPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showUnitPane = false
    }

    SettingsTaskPane {
        id: taskTypePane
        height: parent.height
        width: paneWidth
        visible: showTaskTypePane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showTaskTypePane = false
    }
}
