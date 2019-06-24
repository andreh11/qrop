import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: control

    property int plantingId: -1
    property int locationId: -1
    property date todayDate
    property bool showGreenhouseSow: true
    property bool showNames: false
    property bool showOnlyActiveColor: false
    property bool dragActive: false
    property bool showFamilyColor: false
    property int season
    property int year
    property date seasonBegin

    property var drawMap: Planting.drawInfoMap(plantingId, season, year, showGreenhouseSow, showFamilyColor)
    property color cropColor: drawMap["color"]

    readonly property bool current: Planting.isActive(plantingId)
    readonly property alias hovered: dragArea.containsMouse

    signal selected(int id)
    signal plantingMoved()
    signal plantingRemoved()
    signal dragFinished();

    property bool useStandardBedLength
    property int standardBedLength
    property bool showPlantingSuccessionNumber

    function refresh() {
        plantingIdChanged();
    }

    height: Units.rowHeight
    implicitHeight: Units.rowHeight
    width: harvestBar.x + harvestBar.width

//    anchors {
//        left: parent.left
////        leftMargin: Helpers.position(seasonBegin, showGreenhouseSow ? seedingDate : plantingDate)
//        leftMargin: positions[0]
//    }
    x: drawMap["graphStart"]
    z: dragArea.containsMouse ? 4 : 1

    ToolTip.visible: dragArea.containsMouse
    ToolTip.delay: 200
    ToolTip.onVisibleChanged: ToolTip.text = Planting.toolTip(plantingId, locationId)

    Item {
        id: draggable

        anchors.fill: parent

        Drag.active: control.dragActive && dragArea.drag.active
        Drag.source: dragArea
        Drag.hotSpot.x: width/2
        Drag.hotSpot.y: height/2
        Drag.mimeData: { "text/plain": plantingId + ";" + locationId }
        Drag.dragType: Drag.Automatic
        Drag.onDragFinished: {
            control.dragFinished();
            if (dropAction === Qt.MoveAction) {
                plantingIdChanged();
                if (locationId > 0) {
                    Location.removePlanting(plantingId, locationId)
                    control.plantingRemoved()
                } else {
                    control.plantingMoved();
                }
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: draggable
        hoverEnabled: true
        cursorShape: dragActive ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.PointingHandCursor
        onClicked: if (!dragActive) selected(plantingId)
        onPressed: parent.grabToImage(function(result) {
            draggable.Drag.imageSource = result.url
        })
        onHoveredChanged: {
            if (hovered)
                control.ToolTip.text = Planting.toolTip(plantingId, locationId)
        }
    }

    Label {
        id: seedingLabel
        text: drawMap["sowingDate"]
        color: Material.color(Material.Grey)
        font.family: "Roboto Condensed"
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: seedingCircle.visible

        anchors.right: seedingCircle.left
        anchors.verticalCenter: seedingCircle.verticalCenter
        anchors.rightMargin: 4
    }

    Rectangle {
        id: seedingCircle
        x: -width/4
        visible: showGreenhouseSow && drawMap["greenhouseWidth"]
//        visible: showGreenhouseSow && seedingDate < plantingDate && x < growBar.x
        width: parent.height * 0.3
        anchors.verticalCenter: parent.verticalCenter
        height: width
        radius: 20
        color: current ? Material.color(Material.Green, Material.Shade200)
                       : Material.color(Material.Grey, control.hovered ? Material.Shade500
                                                                       : Material.Shade400)
    }

    Rectangle {
        id: seedingLine
        x: 0
        visible: seedingCircle.visible
        width: drawMap["greenhouseWidth"]
        height: 1
        color: current ? Material.color(Material.Green, Material.Shade200)
                       : Material.color(Material.Grey, control.hovered ? Material.Shade500
                                                                       : Material.Shade400)
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: growBar
//        x: Helpers.widthBetween(control.x, seasonBegin, plantingDate)
        x: drawMap["growStart"]
//        width: Helpers.widthBetween(x+control.x, seasonBegin, beginHarvestDate)
        width: drawMap["growWidth"]
        visible: width > 0
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
        color: {
            if (current || showOnlyActiveColor) {
                if (control.hovered)
                    return Qt.darker(cropColor, 1.1)
                else
                    return cropColor
            } else {
                if (control.hovered)
                    return Material.color(Material.Grey, Material.Shade500)
                else
                    return Material.color(Material.Grey, Material.Shade400)
            }
        }

        Label {
            text: Planting.growBarDescription(plantingId, year, showNames)
            font.family: "Roboto Condensed"
            font.pixelSize: Units.fontSizeBodyAndButton
            antialiasing: true
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }

    Rectangle {
        id: harvestBar
//        x: Helpers.widthBetween(control.x, seasonBegin, beginHarvestDate)
        x: drawMap["harvestStart"]
//        width: Helpers.widthBetween(x+control.x, seasonBegin, endHarvestDate)
        width: drawMap["harvestWidth"]
        visible: width > 0
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
        color: {
            if (current || showOnlyActiveColor) {
                if (control.hovered)
                    return Qt.darker(cropColor, 1.3)
                else
                    return Qt.darker(cropColor, 1.2)
            } else {
                if (control.hovered)
                    return Material.color(Material.Grey, Material.Shade600)
                else
                    return Material.color(Material.Grey, Material.Shade500)
            }
        }

        Label {
            text: drawMap["begHarvestDate"]
            font.family: "Roboto Condensed"
            font.pixelSize: Units.fontSizeBodyAndButton
            antialiasing: true
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }
}
