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
    id: root

    property int paneWidth: 600
    property bool showFamilyPane: false
    property bool showKeywordPane: false
    property bool showSeedCompanyPane: false
    property bool showUnitPane: false
    property bool showTaskTypePane: false

    function refresh() { }

    title: qsTr("Settings")
    Material.background: largeDisplay ? Units.pageColor : "white"

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
        property string preferredLanguage
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
        text: qsTr("Restart the application for modifications to take effect")
        visible: false
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent

        Flickable {
            boundsBehavior: Flickable.StopAtBounds
            visible: !showFamilyPane && !showKeywordPane && !showSeedCompanyPane && !showUnitPane
                     && !showTaskTypePane
            contentHeight: mainColumn.implicitHeight

            Column {
                id: mainColumn
                width: largeDisplay ? paneWidth : parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                //            anchors.top: parent.top
                //            anchors.bottom: parent.bottom

                spacing: Units.smallSpacing
                topPadding: Units.smallSpacing
                bottomPadding: topPadding

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        //                        ThinDivider { width: parent.width }

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

                        RowLayout {
                            width: parent.width
                            Layout.leftMargin: Units.mediumSpacing
                            Layout.rightMargin: Layout.leftMargin

                            Label {
                                Layout.fillWidth: true
                                text: qsTr("Language")
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton
                                elide: Text.ElideRight
                            }

                            ComboBox {
                                Material.elevation: 0
                                font.family: "Roboto Regular"
                                font.pixelSize: Units.fontSizeBodyAndButton
                                Layout.minimumWidth: 200
                                currentIndex: cppQrop.languageCodes.indexOf(settings.preferredLanguage)
                                model: cppQrop.languageNames
                                onCurrentTextChanged: {
                                    settings.preferredLanguage = cppQrop.languageCodes[currentIndex]
                                    restartSnackbar.open();
                                }
                            }
                        }
                    }
                }

                SettingsPaneDivider { }

                PaneTitle {
                    text: qsTr("Beds")
                }

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        RowLayout {
                            width: parent.width
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

                        ThinDivider { width: parent.width }

                        SettingsSwitch {
                            id: standardBedLengthSwitch
                            text: qsTr("Standard bed length")
                            onClicked: restartSnackbar.open();
                        }

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
                            }
                        }
                    }
                }

                SettingsPaneDivider { }

                PaneTitle {
                    text: qsTr("Plantings view")
                }

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        SettingsSwitch {
                            id: showSeedCompanySwitch
                            text: qsTr("Show seed company beside variety names")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: showPlantingSuccessionNumberSwitch
                            text: qsTr("Show planting succession numbers")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: durationsByDefaultSwitch
                            text: qsTr("Compute from durations by default")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: showDurationFieldSwitch
                            text: qsTr("Show duration fields")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: showDensityFieldSwitch
                            text: qsTr("Show density field")
                            onClicked: restartSnackbar.open();
                        }
                    }
                }

                SettingsPaneDivider { }
                PaneTitle {
                    text: qsTr("Field map")
                }

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        SettingsSwitch {
                            id: showFullNameSwitch
                            text: qsTr("Show complete name of locations")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: allowPlantingsConflictSwitch
                            text: qsTr("Allow plantings conflicts on same location")
                            onClicked: restartSnackbar.open();
                        }

                        SettingsSwitch {
                            id: showTaskOnFieldMap
                            text: qsTr("Show tasks")
                            onClicked: restartSnackbar.open();
                        }
                    }
                }

                SettingsPaneDivider { }
                PaneTitle {
                    text: qsTr("Harvests")
                }

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        SettingsSwitch {
                            id: showAllPlantingIfNoneInWindonSwitch
                            text: qsTr("Show all plantings if there is none in harvest window")
                            onClicked: restartSnackbar.open();
                        }
                    }
                }

                SettingsPaneDivider { }
                PaneTitle { text: qsTr("Lists") }

                SettingsPane {
                    width: parent.width

                    ColumnLayout {
                        width: parent.width
                        spacing: 0

                        SettingsPaneButton {
                            text: qsTr("Families, crops and varieties")
                            onClicked: showFamilyPane = true
                        }

                        SettingsPaneButton {
                            text: qsTr("Keywords")
                            onClicked: showKeywordPane = true
                        }

                        SettingsPaneButton {
                            text: qsTr("Seed companies")
                            onClicked: showSeedCompanyPane = true
                        }

                        SettingsPaneButton {
                            text: qsTr("Task types")
                            onClicked: showTaskTypePane = true
                        }

                        SettingsPaneButton {
                            text: qsTr("Units")
                            onClicked: showUnitPane = true
                        }
                    }
                }
            }
        }
    }

    SettingsFamilyPane {
        id: familyPane
        height: parent.height
        width: parent.width
        paneWidth: root.paneWidth
        visible: showFamilyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showFamilyPane = false
        onVisibleChanged: {
            if (visible) {
                refresh();
            }
        }
    }

    SettingsKeywordPane {
        id: keywordPane
        height: parent.height
        width: parent.width
        paneWidth: root.paneWidth
        visible: showKeywordPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showKeywordPane = false
        onVisibleChanged: {
            if (visible) {
                refresh();
            }
        }
    }

    SettingsSeedCompanyPane {
        id: seedCompanyPane
        height: parent.height
        width: parent.width
        paneWidth: root.paneWidth
        visible: showSeedCompanyPane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showSeedCompanyPane = false
        onVisibleChanged: {
            if (visible) {
                refresh();
            }
        }
    }

    SettingsUnitPane {
        id: unitPane
        height: parent.height
        visible: showUnitPane
        width: parent.width
        paneWidth: root.paneWidth
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showUnitPane = false
        onVisibleChanged: {
            if (visible) {
                refresh();
            }
        }
    }

    SettingsTaskPane {
        id: taskTypePane
        height: parent.height
        width: parent.width
        paneWidth: root.paneWidth
        visible: showTaskTypePane
        anchors.horizontalCenter: parent.horizontalCenter
        onClose: showTaskTypePane = false
        onVisibleChanged: {
            if (visible) {
                refresh();
            }
        }
    }
}

