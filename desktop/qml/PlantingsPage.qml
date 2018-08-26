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
    property string filterText: ""
    property int checks: 0
    property int currentYear: 2018
    property int rowHeight: 47
    property int monthWidth: 60

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"
    property var tableHeaderModel: [
        { name: qsTr("Crop"),            columnName: "crop",               width: 100 },
        { name: qsTr("Variety"),         columnName: "variety",            width: 100 },
        { name: qsTr("Seeding Date"),    columnName: "seeding_date",       width: 80 },
        { name: qsTr("Planting Date"),   columnName: "transplanting_date", width: 80 },
        { name: qsTr("Beg. of harvest"), columnName: "beg_harvest_date",   width: 80 },
        { name: qsTr("End of harvest"),  columnName: "end_harvest_date",   width: 80 }
    ]

    onTableSortColumnChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName;
        tableSortOrder = "descending";
        listView.model.setSortColumn(columnName, tableSortOrder);
    }

    onTableSortOrderChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName;
        listView.model.setSortColumn(columnName, tableSortOrder);
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
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: 48

            RowLayout {
                id: filterRow
                anchors.fill: parent
                spacing: 0
                visible: filterMode

                TextField  {
                    id: filterField
                    leftPadding: 16 + largeDisplay ? 50 : 0
                    font.family: "Roboto Regular"
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: 20
                    color: "black"
                    placeholderText: qsTr("Search")
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter

                    Shortcut {
                        sequence: "Escape"
                        onActivated: {
                            filterMode = false
                            filterField.text = ""
                        }
                    }

                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height * 0.7
                        Label {
                            leftPadding: 16
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\ue8b6" // search
                            font.family: "Material Icons"
                            font.pixelSize: 24
                        }
                    }
                }

                IconButton {
                    text: "\ue5cd" // delete
                    onClicked: {
                        filterMode = false
                        filterField.text = ""
                    }
                }
            }

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: 0
                visible: !filterMode

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: checks + " planting" + (checks > 1 ? "s" : "") + " selected"
                    leftPadding: 16
                    color: Material.color(Material.Blue)
                    Layout.fillWidth: true
                    visible: checks > 0
                    font.family: "Roboto Regular"
                    font.pixelSize: 16
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }

                ToolButton {
                    font.pixelSize: fontSizeBodyAndButton
                    leftPadding: 24
                    visible: checks === 0
                    text: qsTr("Add planting")
                    onClicked: plantingDialog.open()
                }

                //                Label {
                //                    text: qsTr("Summer")
                //                    visible: checks === 0
                //                    leftPadding: 16
                //                    font.family: "Roboto Regular"
                //                    font.pixelSize: 20
                ////                    Layout.fillWidth: true
                //                }

                Label {
                    Layout.fillWidth: true
                }

                SpinBox {
                    visible: checks === 0
                    from: 0
                    to: items.length - 1
                    value: 1

                    property var items: ["Spring", "Summer", "Autumn", "Fall"]

                    validator: RegExpValidator {
                        regExp: new RegExp("(Small|Medium|Large)", "i")
                    }

                    textFromValue: function(value) {
                        return items[value];
                    }

                    valueFromText: function(text) {
                        for (var i = 0; i < items.length; ++i) {
                            if (items[i].toLowerCase().indexOf(text.toLowerCase()) === 0)
                                return i
                        }
                        return sb.value
                    }
                }

                CardSpinBox {
                    visible: checks === 0
                    id: yearSpinBox
                    from: 2000
                    to: 2100
                    value: 2018
                }

                IconButton {
                    id: editButton
                    text: "\ue3c9" // edit
                    visible: checks > 0
                    onClicked: {
                        plantingDialog.mode = "edit"
                        plantingDialog.open()
                    }
                }

                IconButton {
                    id: duplicateButton
                    text: "\ue14d" // content_copy
                    visible: checks > 0
                }

                IconButton {
                    id: deleteButton
                    text: "\ue872" // delete
                    visible: checks > 0
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

                IconButton {
                    text: "\ue152" // filter_list
                    visible: checks === 0
                    onClicked: {
                        filterMode = true
                        filterField.focus = true
                    }
                }

                //                IconButton {
                //                    text: "\ue145" // add
                //                    visible: checks === 0
                //                }
            }
        }

        ListView {
            id: listView
            visible: true
            clip: true
            width: parent.width
            height: parent.height - buttonRectangle.height
            spacing: 0
            anchors.top: buttonRectangle.bottom

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

            model: SqlPlantingModel {
                crop: filterField.text
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
                        spacing: 18
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
                                    model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
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
                                            text: modelData
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
                                visible: index > 1
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                            }
                        }
                    }
                }
            }

            delegate: Rectangle {
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
                        spacing: 18
                        leftPadding: 16

                        CheckBox {
                            id: checkBox
                            anchors.verticalCenter: row.verticalCenter
                            width: 24
                            onCheckStateChanged: {
                                if (checked) {
                                    checks = checks + 1
                                } else {
                                    checks = checks - 1
                                }
                            }
                        }

                        TableLabel {
                            text: model.crop
                            elide: Text.ElideRight
                            width: 100
                        }

                        TableLabel {
                            text: model.variety
                            elide: Text.ElideRight
                            width: 100
                        }

                        Timeline {
                            visible: showTimegraph
                            seedingDate: model.seeding_date
                            transplantingDate: model.transplanting_date
                            beginHarvestDate: model.beg_harvest_date
                            endHarvestDate: model.end_harvest_date
                        }

                        TableLabel {
                            text: formatDate(model.seeding_date)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 80
                        }

                        TableLabel {
                            text: formatDate(model.transplanting_date)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 80
                        }

                        TableLabel {
                            text: formatDate(model.beg_harvest_date)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 80
                        }

                        TableLabel {
                            text: formatDate(model.end_harvest_date)
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideRight
                            width: 80
                        }
                    }
                }
            }
        }
    }

    Component {
        id: plantingForm

        PlantingForm {
            anchors.fill: parent
            anchors.margins: 8

        }
    }

    RoundButton {
        id: addButton
        font.family: "Material Icons"
        font.pixelSize: 20
        text: "\ue145"
        width: 56
        height: width
        // Don't want to use anchors for the y position, because it will anchor
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
