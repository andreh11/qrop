import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Item {
    height: parent.height
    width: gridRow.width

    readonly property date yearBegin: new Date(2018, 1, 1)
    property date seedingDate
    property date transplantingDate
    property date beginHarvestDate
    property date endHarvestDate
    property int monthWidth: 60

    function coordinate(day) {
        if (day < 0) {
            return 0
        } else if (day > 365) {
            return 365
        } else {
            return day / 360 * 12 * monthWidth
        }
    }

    function daysDelta(beg, end) {
        return (end - beg) / (1000*60*60*24)
    }

    function position(date) {
        return coordinate(daysDelta(yearBegin, date))
    }

    Row {
        id: gridRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: monthWidth
        Repeater {
            model: 13
            Rectangle {
                height: parent.height
                width: 1
                color: Material.color(Material.Grey, Material.Shade400)
            }
        }
    }

    Rectangle {
        id: seedingCircle
        x: position(seedingDate)
        visible: seedingDate < transplantingDate
        width: parent.height * 0.3
        anchors.verticalCenter: parent.verticalCenter
        height: width
        radius: 20
        color: Material.color(Material.Green, Material.Shade200)
    }

    Rectangle {
        id: seedingLine
        visible: seedingDate < transplantingDate
        width: daysDelta(seedingDate, transplantingDate)
        height: 1
        anchors.left:seedingCircle.right
        color: Material.color(Material.Green, Material.Shade200)
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: growBar
        anchors.left: seedingLine.right
        width: daysDelta(transplantingDate, beginHarvestDate)
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Material.color(Material.Green, Material.Shade200)
    }

    Rectangle {
        id: harvestBar
        anchors.left: growBar.right
        width: daysDelta(beginHarvestDate, endHarvestDate)
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Material.color(Material.Green, Material.Shade600)
    }
}
