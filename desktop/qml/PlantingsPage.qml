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
import QtCharts 2.0

import io.croplan.components 1.0

Page {
    id: page

    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property alias season: seasonCombo.currentIndex
    property string filterText: ""
    property int currentYear: yearSpinBox.value
    property date todayDate: new Date()
    property int rowHeight: 37
    property int monthWidth: 60

    property alias model: listView.model
    property alias plantingModel: plantingModel

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"
    property var tableHeaderModel: [
        { name: qsTr("Crop"), columnName: "crop", width: 100, visible: false },
        { name: qsTr("Variety"), columnName: "variety", width: 100, visible: true },
        { name: qsTr("Sowing"), columnName: "seeding_date", width: 50, visible: true },
        { name: qsTr("Planting"), columnName: "planting_date", width: 50, visible: true },
        { name: qsTr("Begin"), columnName: "beg_harvest_date", width: 50, visible: true },
        { name: qsTr("End"), columnName: "end_harvest_date", width: 50, visible: true },
        { name: qsTr("DTT"), columnName: "dtt", width: 40, visible: true },
        { name: qsTr("DTM"), columnName: "dtm", width: 40, visible: true },
        { name: qsTr("Harvest window"), columnName: "harvest_window", width: 40, visible: true },
        { name: qsTr("Length"), columnName: "length", width: 40, visible: true },
        { name: qsTr("Rows"), columnName: "rows", width: 40, visible: true },
        { name: qsTr("Spacing"), columnName: "Spacing", width: 40, visible: true }
    ]
    property var selectedIds: []
    property int checks: numberOfTrue(selectedIds)

    onTableSortColumnChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName;
        tableSortOrder = "descending";
        listView.model.setSortColumn(columnName, tableSortOrder);
    }

    onTableSortOrderChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName;
        listView.model.setSortColumn(columnName, tableSortOrder);
    }

    function numberOfTrue(array) {
        var n = 0;
        for (var key in array)
            if (array[key])
                n++;
        return n
    }

    function currentSeason() {
        var todayMonth = todayDate.getMonth();
        console.log("Today:", todayDate, "month:", todayMonth)
        if (2 <= todayMonth && todayMonth <= 4)
            return 0;
        else if (5 <= todayMonth && todayMonth <= 7)
            return 1;
        else if (8 <= todayMonth && todayMonth <= 10)
            return 2;
        else
            return 3;
    }

    Component.onCompleted: {
        console.log("Current Season:", currentSeason())
    }

    function duplicateSelected() {
        for (var key in selectedIds)
            if (selectedIds[key]) {
                Planting.duplicate(key);
            }
    }

    function removeSelected() {
        for (var key in selectedIds)
            if (selectedIds[key]) {
                selectedIds[key] = false;
                Planting.remove(key);
            }
        checks = numberOfTrue(selectedIds)
    }

    function formatDate(date) {
        var year = date.getFullYear();
        var text = week(date);
        var prefix = "";

        if (year < currentYear) {
            prefix += "< ";
        } else  if (year > currentYear) {
            prefix += "> ";
        }

        return prefix + text;
    }

    title: "Plantings"
    padding: 8

    PlantingDialog {
        id: plantingDialog
        width: parent.width / 2
        height: parent.height
        x: (parent.width - width) / 2
        model: listView.model
    }

    //    Pane {
    //        id: chartPane
    //        visible: false
    //        height: parent.height/4
    //        width: parent.width
    //        padding: 0
    //        Material.elevation: 1
    //     }

    Pane {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        padding: 0
        Material.elevation: 1

        Rectangle {
            id: buttonRectangle
            //            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            color: checks > 0 ? Material.accent : "white"
            visible: true
            width: parent.width
            height: 48

            //            RowLayout {
            //                id: filterRow
            //                anchors.fill: parent
            //                spacing: 0
            //                visible: filterMode

            ////                TextField  {
            ////                    id: filterField
            ////                    leftPadding: 16 + largeDisplay ? 50 : 0
            ////                    font.family: "Roboto Regular"
            ////                    verticalAlignment: Qt.AlignVCenter
            ////                    font.pixelSize: 20
            ////                    color: "black"
            ////                    placeholderText: qsTr("Search")
            ////                    Layout.fillWidth: true
            ////                    //                    anchors.verticalCenter: parent.verticalCenter

            ////                    Shortcut {
            ////                        sequence: "Escape"
            ////                        onActivated: {
            ////                            filterMode = false
            ////                            filterField.text = ""
            ////                        }
            ////                    }

            ////                    background: Rectangle {
            ////                        anchors.verticalCenter: parent.verticalCenter
            ////                        height: parent.height * 0.7
            ////                        Label {
            ////                            leftPadding: 16
            ////                            color: "black"
            ////                            anchors.verticalCenter: parent.verticalCenter
            ////                            text: "\ue8b6" // search
            ////                            font.family: "Material Icons"
            ////                            font.pixelSize: 24
            ////                        }
            ////                    }
            ////                }

            //                IconButton {
            //                    text: "\ue5cd" // delete
            //                    onClicked: {
            //                        filterMode = false
            //                        filterField.text = ""
            //                    }
            //                }
            //            }

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: 8
                visible: !filterMode

                Button {
                    id: addButton
                    flat: true
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    Material.foreground: Material.accent
                    font.pixelSize: fontSizeBodyAndButton
                    visible: checks === 0
                    text: qsTr("Add planting")
                    onClicked: plantingDialog.open()

                }

                Button {
                    id: editButton
                    Layout.leftMargin: 16 - ((background.width - contentItem.width) / 4)
                    flat: true
                    //                    text: "\ue3c9" // edit
                    text: qsTr("Edit")
                    font.pixelSize: fontSizeBodyAndButton
                    visible: checks > 0
                    Material.foreground: "white"
                    onClicked: {
                        plantingDialog.mode = "edit"
                        plantingDialog.open()
                    }
                }

                Button {
                    id: duplicateButton
                    flat: true
                    //                    text: "\ue14d" // content_copy
                    text: qsTr("Duplicate")
                    visible: checks > 0
                    Material.foreground: "white"
                    font.pixelSize: fontSizeBodyAndButton
                    onClicked: {
                        duplicateSelected();
                        model.refresh();
                    }
                }

                Button {
                    id: deleteButton
                    flat: true
                    font.pixelSize: fontSizeBodyAndButton
                    //                    text: "\ue872" // delete
                    text: qsTr("Delete")
                    visible: checks > 0
                    Material.foreground: "white"
                    onClicked: {
                        removeSelected();
                        model.refresh();
                    }
                }

                Label {
                    visible: deleteButton.visible
                    Layout.fillWidth: true
                }


                TextArea  {
                    id: filterField
                    visible: checks === 0
            leftPadding: searchLogo.width + 16
                    font.family: "Roboto Regular"
                    font.pixelSize: fontSizeBodyAndButton
                    color: "black"
                    placeholderText: qsTr("Search")
                    Layout.fillWidth: true
                    padding: 8
                    topPadding: 16

                    Shortcut {
                        sequence: "Escape"
                        onActivated: {
                            filterMode = false
                            filterField.text = ""
                        }
                    }

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 200
            implicitHeight: 20
//                        width: parent.width
                        height: parent.height * 0.7
                        color: Material.color(Material.Grey, Material.Shade400)
                        radius: 4
                        opacity: 0.1
                    }

                Label {
                    id: searchLogo
//                    visible: filterField.visible
                    color: "black"
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
                    text: "\ue8b6" // search
                    font.family: "Material Icons"
                    font.pixelSize: 24
                }

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

//                CardSpinBox {
//                    id: seasonSpinBox
//                    visible: checks === 0
//                    from: 0
//                    to: items.length - 1
//                    value: 1
//                    width: 150

////                    up.indicator.x: down.indicator.width
////                    contentItem.anchors.left: up.indicator.right
////                    background.height: 0

//                    property var items: [qsTr("Spring"), qsTr("Summer"), qsTr("Fall"), qsTr("Winter")]

//                    validator: RegExpValidator {
//                        regExp: new RegExp("(Small|Medium|Large)", "i")
//                    }

//                    textFromValue: function(value) {
//                        return items[value];
//                    }

//                    valueFromText: function(text) {
//                        for (var i = 0; i < items.length; ++i) {
//                            if (items[i].toLowerCase().indexOf(text.toLowerCase()) === 0)
//                                return i
//                        }
//                        return sb.value
//                    }
//                }

                ComboBox {
                    id: seasonCombo
                    model: [qsTr("Spring"), qsTr("Summer"), qsTr("Fall"), qsTr("Winter")]
                    flat: true
                    currentIndex: currentSeason()
                }

                CardSpinBox {
                    visible: checks === 0
                    id: yearSpinBox
                    from: 2000
                    to: 2100
                    value: new Date().getFullYear()
                    width: 100
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

                //                IconButton {
                //                    text: "\ue152" // filter_list
                //                    visible: checks === 0
                //                    onClicked: {
                //                        filterMode = true
                //                        filterField.focus = true
                //                    }
                //                }
            }
        }

        ThinDivider {
            id: topDivider
            anchors.top: buttonRectangle.bottom
        }

        ListView {
            id: listView
            visible: model.rowCount() > 0
            clip: true
            width: parent.width
            height: parent.height - buttonRectangle.height
            spacing: 0
            anchors.top: topDivider.bottom

            property string filterColumn: "crop"
            //            property TableHeaderLabel filterLabel: headerRow.cropLabel


            //            onFilterLabelChanged: {
            //                console.log("changed!")
            //                switch (filterLabel) {
            //                case cropLabel:
            //                    listView.model.setSortColumn("crop", filterLabel.state)
            //                    break
            //                case varietyLabel:
            //                    listView.model.setSortColumn("variety", filterLabel.state)
            //                    break
            //                }
            //            }

            ScrollBar.vertical: ScrollBar {
                visible: largeDisplay
                parent: listView.parent
                anchors.top: listView.top
                anchors.right: listView.right
                anchors.bottom: listView.bottom
            }

            Shortcut {
                sequence: "Ctrl+K"
                onActivated: {
                    filterMode = true
                    filterField.focus = true
                }
            }

            model: PlantingModel {
                id: plantingModel
                filterString: filterField.text
                year: yearSpinBox.value
                season: page.season
            }

            headerPositioning: ListView.OverlayHeader

            header: Rectangle {
                id: headerRectangle
                height: headerRow.height
                width: parent.width
                color: "white"
                z: 3

                Column {
                    width: parent.width

                    Row {
                        id: headerRow
                        height: rowHeight
                        spacing: 16
                        leftPadding: 16

                        CheckBox {
                            id: headerCheckbox
                            width: 24
                            anchors.verticalCenter: headerRow.verticalCenter
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
                                        width: monthWidth + 1
                                        height: parent.height
                                        Rectangle {
                                            id: lineRectangle
                                            height: parent.height
                                            width: 1
                                            color: Material.color(Material.Grey, Material.Shade400)
                                        }
                                        Label {
                                            text: Qt.locale().monthName(modelData, Locale.ShortFormat)
                                            anchors.left: lineRectangle.right
                                            font.family: "Roboto Condensed"
                                            color: Material.color(Material.Grey, Material.Shade700)
                                            width: 60 - 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            horizontalAlignment: Text.AlignHCenter

                                        }
                                    }
                                }
                                Rectangle {
                                    height: parent.height
                                    width: 1
                                    color: Material.color(Material.Grey, Material.Shade400)
                                }
                            }
                        }

                        Repeater {
                            model: page.tableHeaderModel

                            TableHeaderLabel {
                                text: modelData.name
                                width: modelData.width
                                visible: index > 1 && tableHeaderModel[index].visible
                                horizontalAlignment: Text.AlignRight
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                            }
                        }
                    }
                }

                MouseArea {
                    id: headerMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: popup.open()

                Popup {
                    id: popup
                    x: headerMouseArea.mouseX
                    y: headerMouseArea.mouseY
                    width: 150
                    height: 300
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                    padding: 0

                    contentItem: Rectangle {
                        clip: true
                        width: 150
                        height: 300

                        ListView {
                            spacing: -16
                            anchors.fill: parent
                            model: tableHeaderModel
                            delegate:  CheckBox {
                                text: modelData.name
                                checked: modelData.visible
                                onCheckedChanged: {
                                    console.log(index)
                                    tableHeaderModel[index].visible = checked
                                    console.log(tableHeaderModel[index].visible)
                                }
                            }
                            ScrollBar.vertical: ScrollBar {
                                visible: largeDisplay
                                parent: parent.parent
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                            }

                        }
                    }
                }
                }

            }

            delegate: Rectangle {
                id: delegate
                property date seedingDate: model.planting_type === 2 ? addDays(transplantingDate, -model.dtt)
                                             : transplantingDate
                property date transplantingDate: model.planting_date
                property date beginHarvestDate: addDays(model.planting_date, model.dtm)
                property date endHarvestDate: addDays(beginHarvestDate, model.harvest_window)

                height: row.height
                width: parent.width
                color: {
                    if (checkBox.checked) {
                        return Material.color(Material.Grey, Material.Shade200)
                    } else if (mouseArea.containsMouse) {
                        return Material.color(Material.Grey, Material.Shade100)
                    } else {
                        return "white"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Column {
                    width: parent.width

                    ThinDivider {
                    }

                    Row {
                        id: row
                        height: rowHeight
                        spacing: 16
                        leftPadding: 16

                        TextCheckBox {
                            id: checkBox
                            text: model.crop
                            anchors.verticalCenter: row.verticalCenter
                            width: 24
                            checked: model.planting_id in selectedIds ? selectedIds[model.planting_id] : false
                            onCheckStateChanged: {
                                selectedIds[model.planting_id] = checked
                                checks = numberOfTrue(selectedIds)
                            }
                        }

                        //                        TableLabel {
                        //                            text: model.crop
                        //                            elide: Text.ElideRight
                        //                            width: 100
                        //                        }

                        TableLabel {
                            text: model.variety
                            elide: Text.ElideRight
                            width: 100
                        }

                        Timeline {
                            year: currentYear
                            visible: showTimegraph
                            seedingDate: delegate.seedingDate
                            transplantingDate: delegate.transplantingDate
                            beginHarvestDate: delegate.beginHarvestDate
                            endHarvestDate: delegate.endHarvestDate
                        }

                        TableLabel {
                            text: model.planting_type !== 3 ? formatDate(seedingDate) : ""
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 50
                        }

                        TableLabel {
                            text: model.planting_type !== 1 ? formatDate(transplantingDate) : ""
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 50
                        }

                        TableLabel {
                            text: formatDate(beginHarvestDate)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 50
                        }

                        TableLabel {
                            text: formatDate(endHarvestDate)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 50
                        }
                    }
                }
            }
        }



    }

    Component {
        id: plantingForm

        Page {
            title: qsTr("Add plantings")
            PlantingForm {
                anchors.fill: parent
                anchors.margins: 16

            }
        }
    }

    RoundButton {
        font.family: "Material Icons"
        font.pixelSize: 20
        text: "\ue145"
        width: 56
        height: width
        // Cannot use anchors for the y position, because it will anchor
        // to the footer, leaving a large vertical gap.
        y: parent.height - height
        anchors.right: parent.right
        //        anchors.margins: 12
        visible: !largeDisplay
        highlighted: true

        onClicked: { stackView.push(plantingForm)
        }
    }

}
