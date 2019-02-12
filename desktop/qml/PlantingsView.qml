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

    property int rowPadding: 16
    property int rowSpacing: Units.smallSpacing
    property int checkBoxWidth: Units.rowHeight * 0.8
    readonly property int firstColumnWidth: rowPadding + rowSpacing * 2 + checkBoxWidth + tableHeaderModel[2].width

    property alias showOnlyGreenhouse: plantingModel.showOnlyGreenhouse
    property alias showOnlyUnassigned: plantingModel.showOnlyUnassigned
    property alias rowsNumber: plantingModel.rowCount
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
            "name": qsTr("Locations"),
            "columnName": "locations",
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

    signal dragFinished()

    // Ids of selected plantings
    property var selectedIds: ({})
    // Number of selected plantings
    property int checks: numberOfTrue(selectedIds)
    property int lastIndexClicked: -1

    function numberOfTrue(array) {
        var n = 0
        for (var key in array)
            if (array[key])
                n++
        return n
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

    focus: true
    onTableSortColumnChanged: tableSortOrder = "ascending"
    clip: true
    width: parent.width - verticalScrollBar.width
    spacing: 0
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    rightMargin: verticalScrollBar.width
    bottomMargin: horizontalScrollBar.height
    contentWidth: contentItem.childrenRect.width
    contentHeight: contentItem.childrenRect.height
    highlightMoveDuration: 0
    highlightResizeDuration: 0
    highlight: Rectangle {
        visible: listView.activeFocus
        z:3;
        opacity: 0.1;
        color: Material.primary
        radius: 2
    }

    implicitWidth: contentWidth
    implicitHeight: contentHeight

//    Keys.onUpPressed: verticalScrollBar.decrease()
//    Keys.onDownPressed: verticalScrollBar.increase()
    Keys.onRightPressed: horizontalScrollBar.increase()
    Keys.onLeftPressed: horizontalScrollBar.decrease()
    Keys.onSpacePressed: currentItem.checkBox.select()

    model: PlantingModel {
        id: plantingModel
        year: listView.year
        season: listView.season
        sortColumn: tableHeaderModel[tableSortColumn].columnName
        sortOrder: tableSortOrder
    }

    Settings {
        id: settings
        property bool showSeedCompanyBesideVariety
        property bool useStandardBedLength
        property int standardBedLength
    }

    ScrollBar.vertical: ScrollBar {
        id: verticalScrollBar
        visible: showVerticalScrollBar
        parent: listView.parent
        anchors {
            top: listView.top
            right: listView.right
            bottom: horizontalScrollBar.top
        }
        active: horizontalScrollBar.active
//        policy: ScrollBar.AlwaysOn
    }

    ScrollBar.horizontal: ScrollBar {
        id: horizontalScrollBar
        visible: showHorizontalScrollBar
        active: verticalScrollBar.active
        parent: listView.parent
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: verticalScrollBar.left
        }
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
                spacing: 8
                leftPadding: 16

                CheckBox {
                    id: headerCheckbox
                    width: parent.height * 0.8
                    anchors.verticalCenter: headerRow.verticalCenter
                    tristate: true
                    checkState: rowsNumber && checks == rowsNumber ? Qt.Checked
                                                     : (checks > 0 ? Qt.PartiallyChecked : Qt.Unchecked)
                    nextCheckState: function () {
                        if (!rowsNumber)
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
                        width: modelData.width
                        state: listView.tableSortColumn === index ? listView.tableSortOrder : ""
                        visible: index > 0 && tableHeaderModel[index].visible
                        onNewColumn: {
                            if (listView.tableSortColumn !== index) {
                                listView.tableSortColumn = index
                                listView.tableSortOrder = "descending"
                            }
                        }
                        onNewOrder: listView.tableSortOrder = order
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
                            model: monthsOrder[listView.season]
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
                            height: parent.height; width: 1; color: Qt.rgba(0, 0, 0, 0.12)
                        }
                    }
                }

                Repeater {
                    model: listView.showOnlyTimegraph ? [] : listView.tableHeaderModel

                    TableHeaderLabel {
                        text: modelData.name
                        width: modelData.width
                        visible: index > 1 && tableHeaderModel[index].visible
                        horizontalAlignment: Text.AlignRight
                        state: listView.tableSortColumn === index ? listView.tableSortOrder : ""
                        onNewColumn: {
                            if (listView.tableSortColumn !== index) {
                                listView.tableSortColumn = index
                                listView.tableSortOrder = "descending"
                            }
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
    }

    delegate: Rectangle {
        id: delegate

        property alias checkBox: checkBox

        property date seedingDate: model.sowing_date
        property date transplantingDate: model.planting_date
        property date beginHarvestDate: model.beg_harvest_date
        property date endHarvestDate: model.end_harvest_date

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
                spacing: listView.rowSpacing
                leftPadding: listView.rowPadding

                readonly property var labelList: [
                    [Location.fullName(model.locations.split(",")), Text.AlignRight],
                    [model.planting_type !== 3 ? MDate.formatDate(seedingDate, year) : "",
                     Text.AlignRight],
                    [model.planting_type !== 1 ? MDate.formatDate(transplantingDate, year) : "",
                     Text.AlignRight],
                    [MDate.formatDate(beginHarvestDate, year), Text.AlignRight],
                    [MDate.formatDate(endHarvestDate, year), Text.AlignRight],
                    [model.planting_type === 2 ? qsTr("%L1 d", "Abbreviation for day").arg(model.dtt)
                                               : "",
                     Text.AlignRight],
                    [qsTr("%L1 d", "Abbreviation for day").arg(model.dtm), Text.AlignRight],
                    [qsTr("%L1 d", "Abbreviation for day").arg(model.harvest_window),
                     Text.AlignRight],
                    [settings.useStandardBedLength
                     ? qsTr("%L1 bed", "", model.length/settings.standardBedLength).arg(model.length/settings.standardBedLength)
                     : qsTr("%L1 m", "Abbreviation for meter").arg(model.length), Text.AlignRight],
                    [model.rows, Text.AlignRight],
                    [model.spacing_plants + " cm", Text.AlignRight],
                    [model.yield_per_bed_meter + " " + model.unit, Text.AlignRight],
                    ["%L1 €".arg(model.average_price), Text.AlignRight]
                ]

                TextCheckBox {
                    id: checkBox

                    function select() {
                        selectedIds[model.planting_id] = !selectedIds[model.planting_id]
                        lastIndexClicked = index
                        selectedIdsChanged()
                    }

                    text: model.crop
                    selectionMode: checks > 0
                    anchors.verticalCenter: row.verticalCenter
                    //                                width: 24
                    width: listView.checkBoxWidth
                    round: true
                    color: model.crop_color
                    checked: model.planting_id in selectedIds && selectedIds[model.planting_id]

                    MouseArea {
                        id: checkBoxMouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (mouse.button !== Qt.LeftButton)
                                return
                            parent.select()
                        }
                    }
                }

                TableLabel {
                    text: settings.showSeedCompanyBesideVariety
                          ? "%1 (%2.)".arg(model.variety).arg(model.seed_company.slice(0,3))
                          : "%1".arg(model.variety)
                    showToolTip: true
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: 100

                    Image {
                        z: -1
                        visible: model.in_greenhouse === 1
                        height: parent.height
                        anchors.right: parent.right
                        fillMode: Image.PreserveAspectFit
                        source: "/ghicon.png"

                    }
                }

                Timeline {
                    height: parent.height
                    year: listView.year
                    season: listView.season
                    visible: showTimegraph
                    dragActive: listView.dragActive
                    plantingIdList: [model.planting_id]
                    showOnlyActiveColor: listView.showOnlyActiveColor
                    showFamilyColor: listView.showFamilyColor
                    onPlantingMoved: listView.resetFilter()
                    onDragFinished: listView.dragFinished()
                }

                Repeater {
                    model: listView.showOnlyTimegraph ? [] : parent.labelList

                    TableLabel {
                        text: modelData[0]
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: modelData[1]
                        elide: Text.ElideRight
                        visible: tableHeaderModel[index+2].visible
                        width: tableHeaderModel[index+2].width
                    }
                }
            }
        }
    }
}
