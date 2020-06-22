/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
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

ListView {
    id: listView

    property int year
    property int season

    property int rowPadding: 8
    property int rowSpacing: 8
    property int checkBoxWidth: Units.rowHeight * 0.8
    readonly property int firstColumnWidth: rowPadding + rowSpacing * 2 + checkBoxWidth + tableHeaderModel[2].width
    property alias revenue: plantingModel.revenue
    property alias totalBedLength: plantingModel.totalBedLength
    property alias keywordId: plantingModel.keywordId

    property alias showOnlyGreenhouse: plantingModel.showOnlyGreenhouse
    property alias showOnlyField: plantingModel.showOnlyField
    property alias showOnlyUnassigned: plantingModel.showOnlyUnassigned
    property alias showFinished: plantingModel.showFinished
    property alias rowCount: plantingModel.rowCount
    property bool showOnlyActiveColor: false
    property bool showFamilyColor: false
    property bool showOnlyTimegraph: false
    property bool showHorizontalScrollBar: true
    property bool showVerticalScrollBar: true
    property bool showHeader: true
    property alias filterString: plantingModel.filterString
    property bool showTimegraph: true
    property bool dragActive: false
    property string filterColumn: "crop"
    property int tableSortColumn: 4
    property string tableSortOrder: "ascending"

    property var tableHeaderModel: [{
            "name": qsTr("Crop"),
            "columnName": "crop",
            "width": 100,
            "visible": false,
            "alignment": Qt.AlignLeft
        }, {
            "name": qsTr("Variety"),
            "columnName": "variety",
            "width": 100,
            "visible": true,
            "alignment": Qt.AlignLeft
        }, {
            "name": qsTr("Locations"),
            "columnName": "locations",
            "width": 100,
            "visible": true,
            "alignment": Qt.AlignLeft
        }, {
            "name": qsTr("Sowing"),
            "columnName": "sowing_date",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight
        }, {
            "name": qsTr("Planting"),
            "columnName": "planting_date",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Begin"),
            "columnName": "beg_harvest_date",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("End"),
            "columnName": "end_harvest_date",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("DTT"),
            "columnName": "dtt",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("DTM"),
            "columnName": "dtm",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Harvest Window"),
            "columnName": "harvest_window",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Length"),
            "columnName": "length",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Rows"),
            "columnName": "rows",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Spacing"),
            "columnName": "spacing_plants",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Avg. Yield"),
            "columnName": "yield_per_bed_m",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight

        }, {
            "name": qsTr("Avg. Price"),
            "columnName": "average_price",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight
        }, {
            "name": qsTr("Revenue"),
            "columnName": "bed_revenue",
            "width": 60,
            "visible": true,
            "alignment": Qt.AlignRight
        }, {
            "name": qsTr("Tags"),
            "columnName": "planting_id",
            "width": 120,
            "visible": true,
            "alignment": Qt.AlignLeft
        }
    ]

    property var visibleColumnIdList: {
        var list = [];
        for (var i = 0; i < tableHeaderModel.length; i++) {
            if (tableHeaderModel[i].visible)
                list.push(i);
        }
        return list;
    }

    signal dragFinished()
    signal doubleClicked(int plantingId)

    //! Ids of selected plantings
    property var selectedIds: ({})
    property int lastSelectedRow: -1
    //! Number of selected plantings
    property int checks: numberOfTrue(selectedIds)
    property int firstSelectedIndex: -1
    property int secondSelectedIndex: -1

    function refreshCurrentRow() {
        plantingModel.refreshRow(lastSelectedRow);
    }

    function numberOfTrue(array) {
        var n = 0
        for (var key in array)
            if (array[key])
                n++
        return n
    }

    function shiftSelectBetween() {
        var min = Math.min(firstSelectedIndex, secondSelectedIndex)
        var max = Math.max(firstSelectedIndex, secondSelectedIndex)

        for (var row = min; row <= max; row++)
            selectedIds[plantingModel.rowId(row)] = true;
        selectedIdsChanged();
        firstSelectedIndex = -1
        secondSelectedIndex = -1
    }

    function selectAll() {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = true;
        selectedIdsChanged();
    }

    function unselectAll() {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = false
        selectedIdsChanged();
    }

    function refresh()  {
        var currentY = listView.contentY
        model.refresh();
        listView.contentY = currentY
    }

    function resetFilter() {
        plantingModel.resetFilter();
    }

    function select(plantingId, index) {
        if (selectedIds[plantingId])
            firstSelectedIndex = -1;
        else
            firstSelectedIndex = index;

        selectedIds[plantingId] = !selectedIds[plantingId];
        lastSelectedRow = firstSelectedIndex

        secondSelectedIndex = -1;
        selectedIdsChanged();
    }

    function shiftSelect(plantingId, index) {
        selectedIds[plantingId] = !selectedIds[plantingId]
        if (firstSelectedIndex >= 0) {
            secondSelectedIndex = index;
            lastSelectedRow = secondSelectedIndex
            shiftSelectBetween();
        } else {
            select(plantingId, index);
        }
    }

    function restoreVisibleColumnsSettings() {
        var j = 0; // visibleColumnList index
        for (var i = 0; i < tableHeaderModel.length; i++) {
            while (settings.visibleColumnList[j] < i)
                j++;

            if (Number(settings.visibleColumnList[j]) === i)
                tableHeaderModel[i].visible = true;
            else
                tableHeaderModel[i].visible = false;
        }
        tableHeaderModelChanged();
    }

    // Save visible columns setting.
    onVisibleColumnIdListChanged: settings.visibleColumnList = visibleColumnIdList

    Component.onCompleted: restoreVisibleColumnsSettings()

    focus: true
    clip: true
    width: parent.width - verticalScrollBar.width
    spacing: 0
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    rightMargin: verticalScrollBar.width
    bottomMargin: horizontalScrollBar.height
    contentWidth: contentItem.childrenRect.width
    //    contentHeight: contentItem.childrenRect.height
    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        visible: listView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }
    cacheBuffer: Units.rowHeight*4

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    Keys.onRightPressed: horizontalScrollBar.increase()
    Keys.onLeftPressed: horizontalScrollBar.decrease()
    Keys.onPressed: {
        if (event.key === Qt.Key_Space) {
            if (event.modifiers & Qt.ShiftModifier)
                shiftSelect(currentItem.plantingId, currentIndex)
            else
                select(currentItem.plantingId, currentIndex)
        }
    }

    Settings {
        id: settings
        property bool showSeedCompanyBesideVariety
        property bool useStandardBedLength
        property int standardBedLength
        property string dateType
        property var visibleColumnList
    }

    model: PlantingModel {
        id: plantingModel
        year: listView.year
        season: listView.season
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        visible: showVerticalScrollBar
        active: horizontalScrollBar.active
//        policy: ScrollBar.AlwaysOn
    }

    ScrollBar.horizontal: ScrollBar {
        id: horizontalScrollBar
        visible: showHorizontalScrollBar
        active: verticalScrollBar.active
        orientation: Qt.Horizontal
//        policy: ScrollBar.AlwaysOn
    }

    headerPositioning: ListView.OverlayHeader
    header: Rectangle {
        id: headerRectangle
        visible: listView.showHeader
        height: visible ? headerRow.height : 0
        implicitWidth: headerRow.width
        color: "white"
        z: 5

        MouseArea {
            id: headerMouseArea

            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: columnPopup.open()
            Row {
                id: headerRow
                height: Units.rowHeight
                spacing: listView.rowSpacing
                leftPadding: listView.rowPadding

                CheckBox {
                    id: headerCheckbox
                    width: parent.height * 0.8
                    anchors.verticalCenter: headerRow.verticalCenter
                    tristate: true
                    checkState: rowCount && checks == rowCount ? Qt.Checked
                                                               : (checks > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                    nextCheckState: function () {
                        if (!rowCount)
                            return;

                        if (checkState == Qt.Checked) {
                            unselectAll()
                            return Qt.Unchecked
                        } else {
                            selectAll()
                            return Qt.Checked
                        }
                    }
                }

                Repeater {
                    model: listView.tableHeaderModel.slice(0, 2)

                    TableHeaderLabel {
                        text: modelData.name
                        condensed: true
                        width: modelData.width
                        state: listView.tableSortColumn === index ? listView.tableSortOrder : ""
                        visible: index > 0 && tableHeaderModel[index].visible
                        onNewColumn: {
                            if (listView.tableSortColumn !== index) {
                                listView.tableSortColumn = index
                            }
                        }
                        onNewOrder: listView.tableSortOrder = order
                    }
                }

                HeaderTimelineRow {
                    id: headerTimelineRow
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    visible: showTimegraph
                    season: listView.season
                }

                Repeater {
                    model: listView.showOnlyTimegraph ? [] : listView.tableHeaderModel

                    TableHeaderLabel {
                        text: modelData.name
                        condensed: true
                        width: modelData.width
                        visible: index > 1 && tableHeaderModel[index].visible
                        horizontalAlignment: tableHeaderModel[index].alignment
                        state: listView.tableSortColumn === index ? listView.tableSortOrder : ""
                        onNewColumn: {
                            if (listView.tableSortColumn !== index)
                                listView.tableSortColumn = index
                        }
                        onNewOrder: listView.tableSortOrder = order
                    }
                }
            }

            Popup {
                id: columnPopup

                x: headerMouseArea.mouseX
                y: headerMouseArea.mouseY
                width: 180
                height: 300
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                padding: 0
                margins: 0

                contentItem: Rectangle {
                    clip: true
                    width: 150
                    height: 300

                    ListView {
                        id: popupListView

                        function toggleColumn(index) {
                            var currentY = popupListView.contentY
                            tableHeaderModel[index + 2].visible
                                    = !tableHeaderModel[index + 2].visible
                            tableHeaderModelChanged()
                            popupListView.contentY = currentY
                        }

                        spacing: -16
                        anchors.fill: parent
                        model: tableHeaderModel.slice(2) // Don't show Crop and Variety.
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: CheckBox {
                            text: modelData.name
                            checked: modelData.visible
                            onClicked: popupListView.toggleColumn(index)
                        }

                        ScrollBar.vertical: ScrollBar {
                            visible: largeDisplay
                            anchors {
                                top: parent.top
                                right: parent.right
                                bottom: parent.bottom
                            }
                            policy: ScrollBar.AlwaysOn
                        }
                    }
                }
            }
        }

        ThinDivider {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }

    delegate: Rectangle {
        id: delegate

        property alias checkBox: checkBox

        property date seedingDate: model.sowing_date
        property date transplantingDate: model.planting_date
        property date beginHarvestDate: model.beg_harvest_date
        property date endHarvestDate: model.end_harvest_date
        property var keywordStringList: model.keywords.length ? model.keywords.split(",") : []
        property int plantingId: model.planting_id

        height: delegateColumn.height
        width: delegateColumn.width
        color: {
            if (checkBox.checked)
                Material.color(Material.Grey, Material.Shade200);
            else if (mouseArea.containsMouse)
                Material.color(Material.Grey, Material.Shade100);
            else
                "white";
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onDoubleClicked: listView.doubleClicked(model.planting_id)
        }

        Column {
            id: delegateColumn
            width: row.width

            Row {
                id: row
                height: Units.rowHeight
                spacing: listView.rowSpacing
                leftPadding: listView.rowPadding

                readonly property var labelList: [
                    model.locations ? Location.fullNameList(model.locations.split(",")) : "",
                    model.planting_type !== 3 ? MDate.formatDate(seedingDate, year) : "",
                    model.planting_type !== 1 ? MDate.formatDate(transplantingDate, year) : "",
                    MDate.formatDate(beginHarvestDate, year),
                    settings.dateType === "week" ? MDate.formatDate(MDate.addDays(endHarvestDate, -7), year)
                                                 : MDate.formatDate(endHarvestDate, year),
                    model.planting_type === 2 ? qsTr("%L1 d", "Abbreviation for day").arg(model.dtt) : "",
                    qsTr("%L1 d", "Abbreviation for day").arg(model.dtm),
                    qsTr("%L1 d", "Abbreviation for day").arg(model.harvest_window),
                    settings.useStandardBedLength
                    ? qsTr("%L1 bed", "", model.length/settings.standardBedLength).arg(model.length/settings.standardBedLength)
                    : qsTr("%L1 m", "Abbreviation for meter").arg(model.length),
                    model.rows,
                    model.spacing_plants + " cm",
                    model.yield_per_bed_meter + " " + model.unit,
                    qsTr("$%L1").arg(model.average_price),
                    qsTr("$%L1").arg(model.bed_revenue)
                ]

                TextCheckBox {
                    id: checkBox
                    text: model.crop
                    rank: model.planting_rank
                    selectionMode: checks > 0
                    anchors.verticalCenter: row.verticalCenter
                    width: listView.checkBoxWidth
                    round: true
                    color: model.crop_color
                    checked: model.planting_id in selectedIds && selectedIds[model.planting_id]

                    MouseArea {
                        id: checkBoxMouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (mouse.button !== Qt.LeftButton)
                                return;

                            if (mouse.modifiers & Qt.ShiftModifier)
                                shiftSelect(model.planting_id, index);
                            else
                                select(model.planting_id, index);
                        }
                    }
                }

                TableLabel {
                    text: settings.showSeedCompanyBesideVariety
                          ? "%1 (%2.)".arg(model.variety).arg(model.seed_company.slice(0,3))
                          : "%1".arg(model.variety)
                    condensed: true
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: 100
                    height: parent.height
                    Canvas {
                        id: mycanvas
                        width: height
                        height: parent.height * 0.6
                        visible: model.in_greenhouse === 1
//                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        z: -1
                        onPaint: {
                            if (model.in_greenhouse === 0)
                                return;
                            var context = getContext("2d");
                            context.fillStyle = "light green"
                            context.strokeStyle = Units.colorMediumEmphasis
                            context.arc(width/2, height, height/2, 0, Math.PI, true)
                            context.stroke();
                        }
                    }
                }

                Timeline {
                    height: parent.height
                    year: listView.year
                    season: listView.season
                    visible: showTimegraph
                    dragActive: listView.dragActive
                    plantingIdList: [model.planting_id]
//                    plantingDrawMapList: [model.infoMap]
                    showOnlyActiveColor: listView.showOnlyActiveColor
                    showFamilyColor: listView.showFamilyColor
                    onPlantingMoved: listView.resetFilter()
                    onDragFinished: listView.dragFinished()
                    onPlantingClicked: listView.doubleClicked(plantingId)
                }

                Repeater {
                    model: listView.showOnlyTimegraph ? [] : parent.labelList

                    TableLabel {
                        text: modelData ? modelData : ""
                        condensed: true
                        color: Units.colorHighEmphasis
                        visible: tableHeaderModel[index+2].visible
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: tableHeaderModel[index+2].alignment
                        width: tableHeaderModel[index+2].width
                    }
                }

                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: keywordStringList
                        delegate: SimpleChip {
                            text: modelData
                            visible: !showOnlyTimegraph && tableHeaderModel[tableHeaderModel.length-1].visible
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            ThinDivider { width: parent.width }
        }
    }
}
