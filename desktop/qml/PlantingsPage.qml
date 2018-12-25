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

import io.croplan.components 1.0
import "date.js" as MDate

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
    property int rowsNumber: model.count
    property alias selectedIds: plantingsView.selectedIds
    property alias checks: plantingsView.checks

    function refresh() {
        plantingsView.refresh();
    }


    function selectedIdList() {
        var idList = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
                selectedIds[key] = false
                idList.push(key)
            }
        return idList;
    }

    function duplicateSelected() {
        var idList = selectedIdList();
        Planting.duplicateList(idList)
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

    title: "Plantings"
    padding: 0
    Material.background: "white"

    Settings {
        id: settings
        property alias tableModel: plantingsView.tableHeaderModel
    }

    PlantingDialog {
        id: plantingDialog
        width: parent.width / 2
        height: parent.height - 2 * Units.smallSpacing
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        model: plantingsView.model
        currentYear: page.year
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

        //        Behavior on y {
        //              NumberAnimation {
        //                  easing.type: Easing.OutQuad;
        //                  easing.amplitude: 1.0;
        //                  easing.period: 1.0;
        //                  duration: 300 }
        //          }

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

        //        Behavior on y {
        //              NumberAnimation {
        //                  easing.type: Easing.OutQuad;
        //                  easing.amplitude: 1.0;
        //                  easing.period: 1.0;
        //                  duration: 300 }
        //          }

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
                        year: todayDate.getFullYear()
                    }
                }
            }

            ThinDivider {
                id: topDivider
                anchors.top: buttonRectangle.bottom
                width: parent.width
            }

            Label {
                id: emptyStateLabel
                text: qsTr('No plantings for this season. Click on "Add Plantings" to begin planning!')
                font { family: "Roboto Regular"; pixelSize: Units.fontSizeHeadline }
                color: Qt.rgba(0, 0, 0, 0.8)
                anchors {
                    top: topDivider.bottom;
                    bottom: parent.bottom;
                    left: parent.left;
                    right: parent.right
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                visible: !plantingsView.visible
            }

            PlantingsView {
                id: plantingsView
                year: page.year
                season: page.season
                visible: page.rowsNumber
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

//    ListView {
//        id: smallListView
//        clip: true
//        visible: !largeDisplay
//        width: parent.width
//        height: parent.height - buttonRectangle.height
//        spacing: 0

//        //                flickableDirection: Flickable.HorizontalAndVerticalFlick
//        property string filterColumn: "crop"
//        //            property TableHeaderLabel filterLabel: headerRow.cropLabel
//        Keys.onUpPressed: verticalScrollBar.decrease()
//        Keys.onDownPressed: verticalScrollBar.increase()

//        model: page.model

//        headerPositioning: ListView.OverlayHeader
//        section.property: "crop"
//        section.delegate: Rectangle {
//            width: parent.width
//            height: 48
//            color: "transparent"
//            RowLayout {
//                anchors.fill: parent
//                //                ThinDivider { width: parent.width }

//                Label {
//                    text: section
//                    font.family: "Roboto Regular"
//                    font.pixelSize: Units.fontSizeBodyAndButton
//                    Layout.fillWidth: true
//                }
//                //                Label {
//                //                    text: ">"
//                //                }
//            }
//        }

//        delegate: Rectangle {
//            id: smallDelegate
//            property date seedingDate: model.planting_type
//                                       === 2 ? MDate.addDays(
//                                                   transplantingDate,
//                                                   -model.dtt) : transplantingDate
//            property date transplantingDate: model.planting_date
//            property date beginHarvestDate: MDate.addDays(model.planting_date,
//                                                          model.dtm)
//            property date endHarvestDate: MDate.addDays(beginHarvestDate,
//                                                        model.harvest_window)

//            height: 48
//            width: parent.width
//            color: {
//                if (smallCheckBox.checked) {
//                    return Material.color(Material.Grey, Material.Shade200)
//                }

//                /*} else if (mouseArea.containsMouse) {
//    return Material.color(Material.Grey, Material.Shade100)
//    }*/ else {
//                    return "white"
//                }
//            }

//            Column {
//                anchors.fill: parent

//                ThinDivider {
//                    width: parent.width
//                }

//                RowLayout {
//                    id: smallRow
//                    height: parent.height
//                    spacing: 8

//                    //                    leftPadding: 16
//                    CheckBox {
//                        id: smallCheckBox
//                        //                        text: model.crop
//                        //                        round: true
//                        //                        anchors.verticalCenter: smallRow.verticalCenter
//                        width: 100
//                        height: width
//                        checked: model.planting_id
//                        in selectedIds ? selectedIds[model.planting_id] : false
//                        onCheckStateChanged: {
//                            selectedIds[model.planting_id] = checked
//                        }
//                    }

//                    ColumnLayout {

//                        //                        Layout.fillWidth: true
//                        TableLabel {
//                            text: model.variety
//                            font.family: "Roboto Regular"
//                            elide: Text.ElideRight
//                            //                        width: 100
//                        }

//                        TableLabel {
//                            font.family: "Roboto Regular"
//                            text: NDate.formatDate(
//                                      model.planting_date, currentYear) + " ⋅ " + model.locations
//                        }
//                    }

//                    Item { Layout.fillWidth: true }

//                    ColumnLayout {
//                        TableLabel {
//                            font.family: "Roboto Regular"
//                            text: model.planting_type !== 3 ? NDate.formatDate(
//                                                                  seedingDate,
//                                                                  currentYear) : ""
//                            horizontalAlignment: Text.AlignRight
//                            elide: Text.ElideRight
//                            //                                            width: 60
//                        }
//                        TableLabel {
//                            font.family: "Roboto Regular"
//                            text: model.length + " m"
//                        }
//                    }
//                }
//            }
//        }
//    }

//    RoundButton {
//        id: roundAddButton
//        font.family: "Material Icons"
//        font.pixelSize: 20
//        text: "\ue145"
//        width: 56
//        height: width
//        anchors.right: parent.right
//        anchors.margins: 12
//        // Cannot use anchors for the y position, because it will anchor
//        // to the footer, leaving a large vertical gap.
//        y: parent.height - height - anchors.margins
//        visible: !largeDisplay
//        highlighted: true

//        onClicked: {
//            var item = stackView.push("MobilePlantingForm.qml");
//            item.setFocus();
//            //            mobilePlantingForm.setFocus();
//        }
//    }
}
