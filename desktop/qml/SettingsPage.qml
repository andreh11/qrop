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

    function refresh() {
        familyPane.refresh();
        keywordPane.refresh();
        seedCompanyPane.refresh();
        unitPane.refresh();
        taskTypePane.refresh();
    }

    title: qsTr("Settings")
    Material.background: Units.pageColor

    Settings {
        id: settings
        //        property alias farmName: farmNameField.text
        property alias showSeedCompanyBesideVariety: showSeedCompanySwitch.checked
        property alias useStandardBedLength: standardBedLengthSwitch.checked
        property alias standardBedLength: standardBedLengthField.text
        property alias standardBedWidth: standardBedWidthField.text
        property alias standardPathWidth: standardPathWidthField.text
        property alias showPlantingSuccessionNumber: showPlantingSuccessionNumberSwitch.checked
        property string dateType
    }

    Settings {
        id: plantingSettings
        category: "PlantingsPane"
        property alias durationsByDefault: durationsByDefaultSwitch.checked
        property alias showDurationFields: showDurationFieldSwitch.checked
        property alias showDensityField: showDensityFieldSwitch.checked
    }

    Settings {
        id: locationSettings
        category: "LocationView"
        property alias showFullName: showFullNameSwitch.checked
        property alias allowPlantingsConflict: allowPlantingsConflictSwitch.checked
        property alias showTasks: showTaskOnFieldMap.checked
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
        id: scrollView
        anchors.fill: parent

        ScrollBar.vertical: ScrollBar {
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom; }
        }

        Flickable {
            boundsBehavior: Flickable.StopAtBounds
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
                                elide: Text.ElideRight
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

                        SettingsSwitch {
                            id: showSeedCompanySwitch
                            text: qsTr("Show seed company beside variety names")
                            onToggled: restartSnackbar.open();
                        }

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: showPlantingSuccessionNumberSwitch
                            text: qsTr("Show planting succession numbers")
                            onToggled: restartSnackbar.open();
                        }

                        Item { Layout.fillHeight: true }
                    }

                }

                Label {
                    text: qsTr("Beds")
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

                        SettingsSwitch {
                            id: standardBedLengthSwitch
                            text: qsTr("Standard bed length")
                            onToggled: restartSnackbar.open();
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
                                elide: Text.ElideRight
                            }

                            MyTextField {
                                id: standardBedLengthField
                                suffixText: qsTr("m")
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: IntValidator { bottom: 1; top: 999 }
                                Layout.topMargin: 6
                                Layout.preferredWidth: 60
                                Layout.minimumWidth: 60
                                //                        helperText: plantsBySquareMeter ? qsTr("Plants/m2: %L1").arg(plantsBySquareMeter) : ""
                            }

                            //                            SpinBox {
                            //                                id: standardBedLengthField
                            //                                from: 0
                            //                                to: 999
                            //                                textFromValue: function(value, locale) {
                            //                                    return "%1 %2".arg(value).arg(qsTr("m"))
                            //                                }
                            //                                valueFromText: function(text, locale) {
                            //                                    var s = text.split(" ");
                            //                                    return Number(s[0]);
                            //                                }
                            //                                Layout.preferredWidth: 180
                            //                            }
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
                                text: qsTr("Bed width")
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton
                                elide: Text.ElideRight
                            }

                            MyTextField {
                                id: standardBedWidthField
                                inputMethodHints: Qt.ImhDigitsOnly
                                suffixText: qsTr("cm")
                                validator: IntValidator { bottom: 1; top: 999 }
                                Layout.topMargin: 6
                                Layout.preferredWidth: 60
                                Layout.minimumWidth: 60
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
                                text: qsTr("Path width")
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton
                                elide: Text.ElideRight
                            }

                            MyTextField {
                                id: standardPathWidthField
                                inputMethodHints: Qt.ImhDigitsOnly
                                suffixText: qsTr("cm")
                                validator: IntValidator { bottom: 1; top: 999 }
                                Layout.topMargin: 6
                                Layout.preferredWidth: 60
                                Layout.minimumWidth: 60
                            }
                        }
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

                        SettingsSwitch {
                            id: durationsByDefaultSwitch
                            text: qsTr("Compute from durations by default")
                            onToggled: restartSnackbar.open();
                        }

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: showDurationFieldSwitch
                            text: qsTr("Show duration fields")
                            onToggled: restartSnackbar.open();
                        }

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: showDensityFieldSwitch
                            text: qsTr("Show density field")
                            enabled: settings.useStandardBedLength
                            onToggled: restartSnackbar.open();
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

                        SettingsSwitch {
                            id: showFullNameSwitch
                            text: qsTr("Show complete name of locations")
                            onToggled: restartSnackbar.open();
                        }

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: allowPlantingsConflictSwitch
                            text: qsTr("Allow plantings conflicts on same location")
                            onToggled: restartSnackbar.open();
                        }

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: showTaskOnFieldMap
                            text: qsTr("Show tasks")
                            onToggled: restartSnackbar.open();
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

                        SettingsSwitch {
                            id: showAllPlantingIfNoneInWindonSwitch
                            text: qsTr("Show all plantings if there is none in harvest window")
                            onToggled: restartSnackbar.open();
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

                        SettingsPaneButton {
                            text: qsTr("Families, crops and varieties")
                            onClicked: showFamilyPane = true
                        }

                        ThinDivider { width: parent.width }

                        SettingsPaneButton {
                            text: qsTr("Keywords")
                            onClicked: showKeywordPane = true
                        }

                        ThinDivider { width: parent.width }

                        SettingsPaneButton {
                            text: qsTr("Seed companies")
                            onClicked: showSeedCompanyPane = true
                        }

                        ThinDivider { width: parent.width }

                        SettingsPaneButton {
                            text: qsTr("Task types")
                            onClicked: showTaskTypePane = true
                        }

                        ThinDivider { width: parent.width }
                        SettingsPaneButton {
                            text: qsTr("Units")
                            onClicked: showUnitPane = true
                        }

                        ThinDivider { width: parent.width }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }

    SettingsFamilyPane {
        id: familyPane
        height: parent.height
        width: parent.width
        paneWidth: page.paneWidth
        visible: showFamilyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showFamilyPane = false
    }

    SettingsKeywordPane {
        id: keywordPane
        height: parent.height
        width: parent.width
        paneWidth: page.paneWidth
        visible: showKeywordPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showKeywordPane = false
    }


    SettingsSeedCompanyPane {
        id: seedCompanyPane
        height: parent.height
        width: parent.width
        paneWidth: page.paneWidth
        visible: showSeedCompanyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showSeedCompanyPane = false
    }

    SettingsUnitPane {
        id: unitPane
        height: parent.height
        visible: showUnitPane
        width: parent.width
        paneWidth: page.paneWidth
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showUnitPane = false
    }

    SettingsTaskPane {
        id: taskTypePane
        height: parent.height
        width: parent.width
        paneWidth: page.paneWidth
        visible: showTaskTypePane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showTaskTypePane = false
    }
}

