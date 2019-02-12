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

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtCharts 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Page {
    id: page

    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property string filterString: filterField.text
    property int year: seasonSpinBox.year
    property alias season: seasonSpinBox.season
    property date todayDate: new Date()
    property alias searchField: filterField

    property alias model: plantingsView.model
    property int rowCount: model.rowCount
    property alias selectedIds: plantingsView.selectedIds
    property alias checks: plantingsView.checks

    signal noteButtonClicked(int plantingId)

    function refresh() {
        plantingsView.refresh();
    }

    function selectedIdList() {
        var idList = []
        for (var key in selectedIds)
            if (selectedIds[key])
                idList.push(key)
        return idList;
    }

    function duplicateSelected() {
        var idList = selectedIdList();
        Planting.duplicateList(idList)
        plantingsView.unselectAll()
        page.refresh()
        plantingsView.selectedIdsChanged();
    }

    function removeSelected() {
        var ids = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
                selectedIds[key] = false
                ids.push(key)
            }
        Planting.removeList(ids)
        page.refresh()
        plantingsView.selectedIdsChanged()
    }

    title: qsTr("Plantings")
    padding: 0
    Material.background: "white"

    Settings {
        id: settings
        property alias tableModel: plantingsView.tableHeaderModel
    }

    Shortcut {
        sequences: ["Ctrl+N"]
        enabled: navigationIndex === 0 && addButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
//        onActivated: plantingDialog.createPlanting();
        onActivated: addButton.clicked()
    }

    Shortcut {
        sequences: ["Ctrl+T"]
        enabled: navigationIndex === 0 && addButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
//        onActivated: plantingDialog.createPlanting();
        onActivated: timegraphButton.toggle();
    }


    Shortcut {
        sequences: [StandardKey.Find]
        enabled: navigationIndex === 0 && filterField.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: filterField.forceActiveFocus();
    }

    Shortcut {
        sequence: "Ctrl+E"
        enabled: navigationIndex === 0 && editButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: editButton.clicked()
    }

    Shortcut {
        sequence: "Ctrl+D"
        enabled: navigationIndex === 0 && duplicateButton.visible && !plantingDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: duplicateButton.clicked()
    }

    Shortcut {
        sequence: StandardKey.Delete
        enabled: navigationIndex === 0 && deleteButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: deleteButton.clicked()
    }

    Shortcut {
        sequence: StandardKey.SelectAll
        enabled: navigationIndex === 0 && !deleteButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: plantingsView.selectAll();
    }

    Shortcut {
        sequence: StandardKey.Deselect
        enabled: navigationIndex === 0 && deleteButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: plantingsView.unselectAll()
    }

    Shortcut {
        sequence: "Ctrl+Right"
        enabled: navigationIndex === 0 && !deleteButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.nextSeason()
    }

    Shortcut {
        sequence: "Ctrl+Left"
        enabled: navigationIndex === 0 && !deleteButton.visible && !plantingDialog.activeFocus

        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.previousSeason();
    }

    Shortcut {
        sequences: ["Up", "Down", "Left", "Right"]
        enabled: navigationIndex === 0 && !plantingsView.activeFocus && !plantingDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: {
            plantingsView.currentIndex = 0
            plantingsView.forceActiveFocus();
        }
    }

    Shortcut {
        sequence: "Ctrl+Up"
        enabled: navigationIndex === 0 && !deleteButton.visible && !plantingDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.nextYear()
    }

    Shortcut {
        sequence: "Ctrl+Down"
        enabled: navigationIndex === 0 && !deleteButton.visible && !plantingDialog.activeFocus
        context: Qt.ApplicationShortcut
        onActivated: seasonSpinBox.previousYear();
    }

    PlantingDialog {
        id: plantingDialog
//        width: parent.width / 2
//        height: parent.height - 2 * Units.smallSpacing
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        model: plantingsView.model
        currentYear: page.season === 3 ? page.year + 1 : page.year
        onPlantingsAdded: {
            addPlantingSnackbar.successions = successions;
            addPlantingSnackbar.open();
            page.refresh();
        }

        onPlantingsModified: {
            editPlantingsSnackBar.successions = successions;
            editPlantingsSnackBar.open();
            plantingsView.unselectAll();
            page.refresh();
        }

        onRejected: plantingsView.unselectAll();
    }

    Snackbar {
        id: addPlantingSnackbar

        property int successions: 0

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Added %L1 planting(s)", "", successions).arg(successions)
        visible: false

        onClicked: {
            Planting.rollback();
            page.refresh();
        }
    }

    Snackbar {
        id: editPlantingsSnackBar

        property int successions: 0

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        text: qsTr("Modified %L1 planting(s)", "", successions).arg(successions)
        visible: false

        onClicked: {
            Planting.rollback();
            page.refresh();
        }
    }

    Column {
        id: columnLayout
        anchors.fill: parent

        spacing: 8

        PlantingsChartPane {
            id: chartPane
            visible: false
            width: parent.width
        }

        Pane {
            width: parent.width
            padding: 0
            height: parent.height
            Material.elevation: 2
            visible: largeDisplay

            Rectangle {
                id: buttonRectangle
                //            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
                color: checks > 0 ? Material.accent : "white"
                visible: true
                width: parent.width
                height: 48

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    id: buttonRow
                    anchors.fill: parent
                    spacing: Units.smallSpacing
                    visible: !filterMode

                    Button {
                        id: addButton
                        text: qsTr("Add plantings")
                        flat: true
                        Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                        Material.foreground: Material.accent
                        font.pixelSize: Units.fontSizeBodyAndButton
                        visible: checks === 0
                        onClicked: plantingDialog.createPlanting()
                    }

                    IconButton {
                        id: timegraphButton
                        text: "\ue0b8"
                        hoverEnabled: true
                        visible: largeDisplay && checks == 0
                        checkable: true
                        checked: true

                        ToolTip.visible: hovered
                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                        ToolTip.text: checked ? qsTr("Hide timegraph") : qsTr("Show timegraph")
                    }

                    Button {
                        id: editButton
                        Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                        flat: true
                        text: qsTr("Edit")
                        font.pixelSize: Units.fontSizeBodyAndButton
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: plantingDialog.editPlantings(selectedIdList())

                    }

                    Button {
                        id: duplicateButton
                        flat: true
                        text: qsTr("Duplicate")
                        visible: checks > 0
                        Material.foreground: "white"
                        font.pixelSize: Units.fontSizeBodyAndButton
                        onClicked: duplicateSelected()
                    }

                    Button {
                        id: deleteButton
                        flat: true
                        font.pixelSize: Units.fontSizeBodyAndButton
                        text: qsTr("Delete")
                        visible: checks > 0
                        Material.foreground: "white"
                        onClicked: removeSelected()
                    }

                    Label {
                        visible: deleteButton.visible
                        Layout.fillWidth: true
                    }

                    SearchField {
                        id: filterField
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhPreferLowercase
                        visible: !checks
                    }

                    Label {
                        text: qsTr("planting(s) selected", "", checks)
                        color: "white"
                        visible: checks > 0
                        font.family: "Roboto Regular"
                        font.pixelSize: 16
                        Layout.rightMargin: 16
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    SeasonSpinBox {
                        id: seasonSpinBox
                        visible: checks === 0
                        season: MDate.season(todayDate)
                        year: MDate.seasonYear(todayDate)
                    }
                }
            }

            ThinDivider {
                id: topDivider
                anchors.top: buttonRectangle.bottom
                width: parent.width
            }

            Column {
                id: blankStateColumn
                z: 1
                spacing: Units.smallSpacing
                visible: !page.rowCount
                anchors {
                    centerIn: parent
                }

                Label {
                    id: emptyStateLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr('No plantings for this season')
                    font { family: "Roboto Regular"; pixelSize: Units.fontSizeTitle }
                    color: Qt.rgba(0, 0, 0, 0.8)
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: qsTr("Add")
                    flat: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    Material.background: Material.accent
                    Material.foreground: "white"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    onClicked: plantingDialog.createPlanting()
                }
            }

            PlantingsView {
                id: plantingsView
                year: page.year
                season: page.season
                showTimegraph: page.showTimegraph
                filterString: page.filterString
                dragActive: false
                anchors {
                    top: topDivider.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

            }
        }
    }
}
