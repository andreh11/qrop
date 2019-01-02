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
                        ToolTip.text: qsTr("Restart the application for this take effect.")
                        ToolTip.visible: hovered
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
                        text: "Keywords"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
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
                        text: "Units"
                        font.family: "Roboto Regular"
                        font.pixelSize: Units.fontSizeBodyAndButton
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
