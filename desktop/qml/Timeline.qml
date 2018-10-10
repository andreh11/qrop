import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0
import "date.js" as MDate

Item {
    id: control
    width: gridRow.width

    property int season: 1
    property int year
    property date todayDate: new Date()
    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    property int monthWidth: 10
    readonly property int graphWidth: 12 * monthWidth
    property date seedingDate
    property date transplantingDate
    property date beginHarvestDate
    property date endHarvestDate

    function coordinate(day) {
        if (day < 0)
            return 0;
        else if (day > 365)
            return graphWidth;
        else
            return (day / 365.0) * graphWidth;
    }

    function widthBetween(pos, date) {
        var width = position(date) - pos;
        if (width > 0)
            return width;
        else
            return 0;
    }

    function daysDelta(beg, end) {
        var msPerDay = 1000 * 60 * 60 * 24;
        return (end - beg) / msPerDay;
    }

    function position(date) {
        return coordinate(daysDelta(seasonBegin, date))
    }

    Row {
        id: gridRow
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: monthWidth - 1

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
        id: januaryLine
        x: position(new Date(year, 0, 1))
        visible: x != 0 && x != graphWidth
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.color(Material.Grey, Material.Shade800)
    }

    Rectangle {
        id: todayLine
        x: position(todayDate)
        z: 1
        visible: x != 0 && x != graphWidth
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Material.accent
    }

    Label {
        id: seedingLabel
        text: MDate.formatDate(seedingDate)
        color: Material.color(Material.Grey)
        font.family: "Roboto Condensed"
        visible: seedingCircle.visible

        anchors.right: seedingCircle.left
        anchors.verticalCenter: seedingCircle.verticalCenter
        anchors.rightMargin: 4
    }

    Rectangle {
        id: seedingCircle
        x: position(seedingDate)
        visible: seedingDate < transplantingDate && x < growBar.x
        width: parent.height * 0.3
        anchors.verticalCenter: parent.verticalCenter
        height: width
        radius: 20
        color: Material.color(Material.Green, Material.Shade200)
    }

    Rectangle {
        id: seedingLine
        width: widthBetween(x, transplantingDate)
        visible: width > 0
        height: 1
        x: seedingCircle.x
        color: Material.color(Material.Green, Material.Shade200)
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: growBar
        x: position(transplantingDate)
        width: widthBetween(x, beginHarvestDate)
        visible: width > 0
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Material.color(Material.Green, Material.Shade300)

        Label {
            text: MDate.formatDate(transplantingDate)
            font.family: "Roboto Condensed"
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }

    Rectangle {
        id: harvestBar
        x: position(beginHarvestDate)
        width: widthBetween(x, endHarvestDate)
        visible: width > 0
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Material.color(Material.Green, Material.Shade700)
        Label {
            text: MDate.formatDate(beginHarvestDate)
            font.family: "Roboto Condensed"
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }
}
