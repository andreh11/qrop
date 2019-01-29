import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

import io.croplan.components 1.0
import "date.js" as MDate

Item {
    id: control

    property int plantingId: -1
    property int locationId: -1
    property date todayDate
    property bool showGreenhouseSow: true
    property bool showNames: false
    property bool showOnlyActiveColor: false
    property bool dragActive: false
    property int year
    property date seasonBegin
    property color cropColor: Planting.cropColor(plantingId)
    property date seedingDate: Planting.sowingDate(plantingId)
    property date plantingDate: Planting.plantingDate(plantingId)
    property date beginHarvestDate: Planting.begHarvestDate(plantingId)
    property date endHarvestDate: Planting.endHarvestDate(plantingId)
    property string cropName: Planting.cropName(plantingId)
    property string varietyName: Planting.varietyName(plantingId)
    property int totalLength: Planting.totalLength(plantingId)
    property int assignedLength: locationId > 0 ? Location.plantingLength(plantingId, locationId) : 0
    property int lengthLeft: Planting.lengthToAssign(plantingId)
    readonly property bool current: seedingDate <= todayDate && todayDate <= endHarvestDate
    readonly property alias hovered: mouseArea.containsMouse
    readonly property bool displaySow: showGreenhouseSow && plantingDate > seasonBegin

    signal selected(int id)
    signal plantingMoved()
    signal plantingRemoved()
    signal dragFinished();

    function refresh() {
        plantingIdChanged();
    }

    height: Units.rowHeight
    implicitHeight: Units.rowHeight
    width: harvestBar.x + harvestBar.width

    x: Units.position(seasonBegin, displaySow ? seedingDate : plantingDate)
    z: mouseArea.containsMouse ? 4 : 1

    ToolTip.text: locationId > 0
                  ? "%1, %2 (%3/%4 m)".arg(cropName).arg(varietyName).arg(assignedLength).arg(totalLength)
                  : "%1, %2 (%3/%4 m)".arg(cropName).arg(varietyName).arg(lengthLeft).arg(totalLength)
    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: 200

    Item {
        id: draggable

        anchors.fill: parent

        Drag.active: control.dragActive && mouseArea.drag.active
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
        id: mouseArea
        drag.target: draggable
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: selected(plantingId)
        onPressed: parent.grabToImage(function(result) {
            draggable.Drag.imageSource = result.url
        })
    }

    Label {
        id: seedingLabel
        text: NDate.formatDate(seedingDate, year, null, false)
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
        x: Units.position(seasonBegin, seedingDate) - width/4 - control.x
        visible: showGreenhouseSow && seedingDate < plantingDate && x < growBar.x
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
        width: Units.widthBetween(x+control.x, seasonBegin, plantingDate)
        visible: showGreenhouseSow && width > 0 && seedingDate < plantingDate
        height: 1
        x: seedingCircle.x
        color: current ? Material.color(Material.Green, Material.Shade200)
                       : Material.color(Material.Grey, control.hovered ? Material.Shade500
                                                                       : Material.Shade400)
        anchors.verticalCenter: parent.verticalCenter
    }
    
    Rectangle {
        id: growBar
        x: Units.position(seasonBegin, plantingDate) - control.x
        width: Units.widthBetween(x+control.x, seasonBegin, beginHarvestDate)
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
            text: NDate.formatDate(plantingDate, year, null, false) + (showNames ? " " + cropName.slice(0,2) + ", " + varietyName
                                                                    : "")
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
        x: Units.position(seasonBegin, beginHarvestDate) - control.x
        width: Units.widthBetween(x+control.x, seasonBegin, endHarvestDate)
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
            text: NDate.formatDate(beginHarvestDate, year, null, false)
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
