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
import QtCharts 2.2
import Qt.labs.settings 1.0

import io.croplan.components 1.0
import "date.js" as MDate

Page {
    id: page

    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property alias season: seasonSpinBox.season
    property string filterText: ""
    property int currentYear: seasonSpinBox.year
    property date todayDate: new Date()

    property alias model: listView.model
    property alias plantingModel: plantingModel
    property int rowsNumber: plantingModel.count

    Settings {
        id: settings
        property alias tableModel: page.tableHeaderModel
    }

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"
    property var tableHeaderModel: [{
            "name": qsTr("Crop"),
            "columnName": "crop",
            "width": 100,
            "visible": false
        }, {
            "name": qsTr("Variety"),
            "columnName": "variety",
            "width": 100,
            "visible": true
        }, {
            "name": qsTr("Sowing"),
            "columnName": "sowing_date",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Planting"),
            "columnName": "planting_date",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Begin"),
            "columnName": "beg_harvest_date",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("End"),
            "columnName": "end_harvest_date",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("DTT"),
            "columnName": "dtt",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("DTM"),
            "columnName": "dtm",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Harvest Window"),
            "columnName": "harvest_window",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Length"),
            "columnName": "length",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Rows"),
            "columnName": "rows",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Spacing"),
            "columnName": "spacing_plants",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Avg. Yield"),
            "columnName": "yield_per_bed_m",
            "width": 60,
            "visible": true
        }, {
            "name": qsTr("Avg. Price"),
            "columnName": "average_price",
            "width": 60,
            "visible": true
        }]
    property var selectedIds: ({})
    property int lastIndexClicked: -1
    property int checks: numberOfTrue(selectedIds)


    function numberOfTrue(array)
    {
        var n = 0
        for (var key in array)
            if (array[key])
                n++
        return n
    }

    // UGLY HACK
    // JS arrays don't emit changed() signal when an element is modified.
    // Unfortunately, it seems to be no way to manually emit the
    // selectedIdsChanged() signal. Hence when have to copy the whole
    // array, which is a really ugly.
    function emitSelectedIdsChanged()
    {
        selectedIds = selectedIds
    }

    // Same ugly hack
    function emitTableHeaderModelChanged()
    {
        tableHeaderModel = tableHeaderModel
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

    function selectAll()
    {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = true
        emitSelectedIdsChanged()
    }

    function unselectAll()
    {
        var list = plantingModel.idList()
        for (var i = 0; i < list.length; i++)
            selectedIds[list[i]] = false
        emitSelectedIdsChanged()
    }

    function duplicateSelected()
    {
        var idList = selectedIdList();
        Planting.duplicateList(idList)
        plantingModel.refresh()
        emitSelectedIdsChanged()
    }

    function removeSelected()
    {
        var ids = []
        for (var key in selectedIds)
            if (selectedIds[key]) {
                selectedIds[key] = false
                ids.push(key)
            }
        Planting.removeList(ids)
        plantingModel.refresh()
        emitSelectedIdsChanged()
    }

    title: "Plantings"
    padding: 8
    Material.background: "white"

    onTableSortColumnChanged: tableSortOrder = "descending"

    Shortcut {
        sequence : "Ctrl+K"
        onActivated: {
            filterField.clear();
            filterField.forceActiveFocus();
        }
    }

    PlantingModel {
        id: plantingModel
        filterString: filterField.text
        year: currentYear
        season: page.season
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    PlantingDialog {
        id: plantingDialog
        width: parent.width / 2
        height: parent.height
        x: (parent.width - width) / 2
        model: listView.model
        currentYear: page.currentYear
        onPlantingsAdded: {
            addPlantingSnackbar.successions = successions
            addPlantingSnackbar.open();
        }

        onPlantingsModified: {
            editPlantingsSnackBar.successions = successions
            editPlantingsSnackBar.open()
            unselectAll();
        }

        onRejected: unselectAll();
    }

    Snackbar {
        id: addPlantingSnackbar

        property int successions: 0

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing - horizontalScrollBar.height
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
            plantingModel.refresh();
        }
    }

    Snackbar {
        id: editPlantingsSnackBar

        property int successions: 0

        z: 2
        x: Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing - horizontalScrollBar.height
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
            plantingModel.refresh();
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

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                RowLayout {
                    id: buttonRow
                    anchors.fill: parent
                    spacing: 8
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
                        visible: largeDisplay && checks == 0 && rowsNumber
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
                        visible: !checks && rowsNumber
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
                        visible: checks === 0 && rowsNumber
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
                text: qsTr('Click on "Add Plantings" to begin planning!')
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
                visible: !plantingModel.count
            }

            ListView {
                id: listView

                property string filterColumn: "crop"

                visible: plantingModel.count
                clip: true
                width: parent.width - verticalScrollBar.width
                height: parent.height - buttonRectangle.height
                spacing: 0
                anchors.top: topDivider.bottom
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalAndVerticalFlick
                rightMargin: verticalScrollBar.width
                bottomMargin: horizontalScrollBar.height
                contentWidth: contentItem.childrenRect.width + Units.smallSpacing
                contentHeight: contentItem.childrenRect.height + Units.smallSpacing

                Keys.onUpPressed: verticalScrollBar.decrease()
                Keys.onDownPressed: verticalScrollBar.increase()
                Keys.onRightPressed: horizontalScrollBar.increase()
                Keys.onLeftPressed: horizontalScrollBar.decrease()

                model: plantingModel

                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollBar
                    visible: largeDisplay && plantingModel.count
                    parent: listView.parent
                    anchors {
                        top: listView.top
                        left: listView.right
                        bottom: horizontalScrollBar.top
                    }
                    active: horizontalScrollBar.active
                    policy: ScrollBar.AlwaysOn
                }

                ScrollBar.horizontal: ScrollBar {
                    id: horizontalScrollBar
                    visible: verticalScrollBar.visible
                    active: verticalScrollBar.active
                    parent: listView.parent
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: verticalScrollBar.left
                    }
                    orientation: Qt.Horizontal
                    policy: ScrollBar.AlwaysOn
                }

                Shortcut {
                    sequence: "Ctrl+K"
                    onActivated: {
                        filterMode = true
                        filterField.forceActiveFocus();
                    }
                }

                headerPositioning: ListView.OverlayHeader

                Component {
                    id: headerDelegate
                    Rectangle {
                        id: headerRectangle
                        height: headerRow.height
                        implicitWidth: headerRow.width
                        color: "white"
                        z: 5

                        Row {
                            id: headerRow
                            height: Units.rowHeight
                            spacing: 8
                            leftPadding: 16

                            CheckBox {
                                id: headerCheckbox
                                width: parent.height * 0.8
//                                width: 24
                                anchors.verticalCenter: headerRow.verticalCenter
                                tristate: true
                                checkState: checks == rowsNumber ? Qt.Checked
                                                                 : (checks > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                                nextCheckState: function () {
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
                                model: page.tableHeaderModel.slice(0, 2)

                                TableHeaderLabel {
                                    text: modelData.name
                                    width: modelData.width
                                    state: page.tableSortColumn === index ? page.tableSortOrder : ""
                                    visible: index > 0 && tableHeaderModel[index].visible
                                }
                            }

                            Item {
                                height: parent.height
                                width: headerTimelineRow.width
                                visible: showTimegraph
                                Row {
                                    id: headerTimelineRow
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: parent.height
                                    spacing: 0

                                    Repeater {
                                        model: monthsOrder[page.season]
                                        Item {
                                            width: Units.monthWidth
                                            height: parent.height

                                            Rectangle {
                                                id: lineRectangle
                                                height: parent.height
                                                width: 1
                                                color: Qt.rgba(0, 0, 0, 0.12)
                                            }

                                            Label {
                                                text: Qt.locale().monthName(modelData,
                                                                            Locale.ShortFormat)
                                                anchors.left: lineRectangle.right
                                                font.family: "Roboto Condensed"
                                                color: Material.color(Material.Grey,
                                                                      Material.Shade700)
                                                width: 60 - 1
                                                anchors.verticalCenter: parent.verticalCenter
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }

                                    Rectangle {
                                        height: parent.height
                                        width: 1
                                        color: Qt.rgba(0, 0, 0, 0.12)
                                    }
                                }
                            }

                            Repeater {
                                model: page.tableHeaderModel

                                TableHeaderLabel {
                                    text: modelData.name
                                    width: modelData.width
                                    visible: index > 1
                                             && tableHeaderModel[index].visible
                                    horizontalAlignment: Text.AlignRight
                                    state: page.tableSortColumn === index ? page.tableSortOrder : ""
                                }
                            }
                        }

                        MouseArea {
                            id: headerMouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: columnPopup.open()

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
                                        spacing: -16
                                        anchors.fill: parent
                                        model: tableHeaderModel.slice(2) // Don't show Crop and Variety.
                                        delegate: CheckBox {
                                            text: modelData.name
                                            checked: modelData.visible
                                            onClicked: {
                                                tableHeaderModel[index + 2].visible
                                                        = !tableHeaderModel[index + 2].visible
                                                emitTableHeaderModelChanged()
                                            }
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
                    }
                }


                header: headerDelegate
                delegate: Rectangle {
                    id: delegate

                    property date seedingDate: {
                        if (model.planting_type === 2)
                            MDate.addDays(transplantingDate, -model.dtt);
                        else
                            transplantingDate;
                    }
                    property date transplantingDate: model.planting_date
                    property date beginHarvestDate: MDate.addDays(model.planting_date, model.dtm)
                    property date endHarvestDate: MDate.addDays(beginHarvestDate,
                                                                model.harvest_window)

                    height: row.height
                    width: headerColumn.width
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
                    }

                    Column {
                        id: headerColumn
                        width: row.width

                        ThinDivider { width: parent.width }

                        Row {
                            id: row
                            height: Units.rowHeight
                            spacing: Units.smallSpacing
                            leftPadding: 16

                            TextCheckBox {
                                id: checkBox
                                text: model.crop
                                selectionMode: checks > 0
                                anchors.verticalCenter: row.verticalCenter
//                                width: 24
                                width: parent.height * 0.8
                                round: true
                                color: model.crop_color
                                checked: model.planting_id in selectedIds
                                         && selectedIds[model.planting_id]

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (mouse.button !== Qt.LeftButton)
                                            return

                                        selectedIds[model.planting_id]
                                                = !selectedIds[model.planting_id]
                                        lastIndexClicked = index
                                        emitSelectedIdsChanged()
                                        console.log("All:", plantingModel.rowCount( ) === checks)
                                    }
                                }
                            }

                            TableLabel {
                                text: model.variety
                                showToolTip: true
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                width: 100
                            }

                            Timeline {
                                height: parent.height
                                year: currentYear
                                season: page.season
                                visible: showTimegraph
                                seedingDate: delegate.seedingDate
                                transplantingDate: delegate.transplantingDate
                                beginHarvestDate: delegate.beginHarvestDate
                                endHarvestDate: delegate.endHarvestDate
                            }

                            TableLabel {
                                text: model.planting_type !== 3 ? NDate.formatDate(
                                                                      seedingDate,
                                                                      currentYear) : ""
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[2].visible
                                width: tableHeaderModel[2].width
                            }

                            TableLabel {
                                text: model.planting_type !== 1 ? NDate.formatDate(
                                                                      transplantingDate,
                                                                      currentYear) : ""
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[3].visible
                                width: tableHeaderModel[3].width
                            }

                            TableLabel {
                                text: NDate.formatDate(beginHarvestDate,
                                                       currentYear)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[4].visible
                                width: tableHeaderModel[4].width
                            }

                            TableLabel {
                                text: NDate.formatDate(endHarvestDate,
                                                       currentYear)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[5].visible
                                width: tableHeaderModel[5].width
                            }

                            TableLabel {
                                text: qsTr("%n d", "Abbreviation for day", model.dtt)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[6].visible
                                width: tableHeaderModel[6].width
                            }

                            TableLabel {
                                text: qsTr("%n d", "Abbreviation for day", model.dtm)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[7].visible
                                width: tableHeaderModel[7].width
                            }

                            TableLabel {
                                text: qsTr("%n d", "Abbreviation for day", model.harvest_window)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[8].visible
                                width: tableHeaderModel[8].width
                            }

                            TableLabel {
                                text: model.length + " m"
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[9].visible
                                width: tableHeaderModel[9].width
                            }

                            TableLabel {
                                text: model.rows
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[10].visible
                                width: tableHeaderModel[10].width
                            }

                            TableLabel {
                                text: model.spacing_plants + " cm"
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[11].visible
                                width: tableHeaderModel[11].width
                            }

                            TableLabel {
                                text: model.yield_per_bed_meter + " " + model.unit
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[12].visible
                                width: tableHeaderModel[12].width
                            }

                            TableLabel {
                                text: "%L1 €".arg(model.average_price)
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                elide: Text.ElideRight
                                visible: tableHeaderModel[13].visible
                                width: tableHeaderModel[13].width
                            }
                        }
                    }
                }

            }
        }
    }


    ListView {
        id: smallListView
        clip: true
        visible: !largeDisplay
        width: parent.width
        height: parent.height - buttonRectangle.height
        spacing: 0

        //                flickableDirection: Flickable.HorizontalAndVerticalFlick
        property string filterColumn: "crop"
        //            property TableHeaderLabel filterLabel: headerRow.cropLabel
        Keys.onUpPressed: verticalScrollBar.decrease()
        Keys.onDownPressed: verticalScrollBar.increase()

        model: plantingModel

        headerPositioning: ListView.OverlayHeader
        section.property: "crop"
        section.delegate: Rectangle {
            width: parent.width
            height: 48
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                ThinDivider { width: parent.width }

                Label {
                    text: section
                    Layout.fillWidth: true
                }
                Label {
                    text: ">"
                }
            }
        }

        delegate: Rectangle {
            id: smallDelegate
            property date seedingDate: model.planting_type
                                       === 2 ? MDate.addDays(
                                                   transplantingDate,
                                                   -model.dtt) : transplantingDate
            property date transplantingDate: model.planting_date
            property date beginHarvestDate: MDate.addDays(model.planting_date,
                                                          model.dtm)
            property date endHarvestDate: MDate.addDays(beginHarvestDate,
                                                        model.harvest_window)

            height: 48
            width: parent.width
            color: {
                if (smallCheckBox.checked) {
                    return Material.color(Material.Grey, Material.Shade200)
                }

                /*} else if (mouseArea.containsMouse) {
    return Material.color(Material.Grey, Material.Shade100)
    }*/ else {
                    return "white"
                }
            }

            Column {
                anchors.fill: parent

                ThinDivider {
                    width: parent.width
                }

                RowLayout {
                    id: smallRow
                    height: parent.height
                    spacing: 8

                    //                    leftPadding: 16
                    CheckBox {
                        id: smallCheckBox
                        //                        text: model.crop
                        //                        round: true
                        //                        anchors.verticalCenter: smallRow.verticalCenter
                        width: 100
                        height: width
                        checked: model.planting_id
                        in selectedIds ? selectedIds[model.planting_id] : false
                        onCheckStateChanged: {
                            selectedIds[model.planting_id] = checked
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        //                        Layout.fillWidth: true
                        TableLabel {
                            text: model.variety
                            elide: Text.ElideRight
                            //                        width: 100
                        }

                        TableLabel {
                            text: NDate.formatDate(
                                      model.planting_date, currentYear) + " ⋅ " + model.locations
                        }
                    }

                    ColumnLayout {
                        TableLabel {
                            text: model.planting_type !== 3 ? NDate.formatDate(
                                                                  seedingDate,
                                                                  currentYear) : ""
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            //                                            width: 60
                        }
                        TableLabel {
                            text: model.length + " m"
                        }
                    }
                }
            }
        }
    }

    RoundButton {
        id: roundAddButton
        font.family: "Material Icons"
        font.pixelSize: 20
        text: "\ue145"
        width: 56
        height: width
        anchors.right: parent.right
        anchors.margins: 12
        // Cannot use anchors for the y position, because it will anchor
        // to the footer, leaving a large vertical gap.
        y: parent.height - height - anchors.margins
        visible: !largeDisplay
        highlighted: true

        onClicked: {
            var item = stackView.push("MobilePlantingForm.qml");
            item.setFocus();
            //            mobilePlantingForm.setFocus();
        }
    }
}
