import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Item {
    height: parent.height
    width: gridRow.width

    property int year
    readonly property date yearBegin: new Date(year, 0, 1)
    readonly property int graphWidth: 12 * monthWidth
    property date seedingDate
    property date transplantingDate
    property date beginHarvestDate
    property date endHarvestDate

    function coordinate(day) {
//        console.log(day)
        if (day < 0) {
            return 0
        } else if (day > 365) {
            return graphWidth
        } else {
            return (day / 365.0) * graphWidth
        }
    }

    function daysDelta(beg, end) {
        var msPerDay = 1000 * 60 * 60 * 24;
        return (end - beg) / msPerDay;
    }

    function position(date) {
        console.log(date.toLocaleString(Qt.locale(), "dd/MM: "), daysDelta(yearBegin, date));
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
        x: position(seedingDate) - width/2
        visible: seedingDate < transplantingDate
        width: parent.height * 0.3
        anchors.verticalCenter: parent.verticalCenter
        height: width
        radius: 20
        color: Material.color(Material.Green, Material.Shade200)
    }

    Label {
        text: formatDate(seedingDate)
        color: Material.color(Material.Grey)
        font.family: "Roboto Condensed"
        visible: seedingCircle.visible
        anchors.right: seedingCircle.left
        anchors.verticalCenter: seedingCircle.verticalCenter
        anchors.rightMargin: 4
    }

    Rectangle {
        id: seedingLine
        visible: seedingDate < transplantingDate
        width: daysDelta(seedingDate, transplantingDate) / 365 * 12 * monthWidth
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
        color: Material.color(Material.Green, Material.Shade300)

        Label {
            text: formatDate(transplantingDate)
            font.family: "Roboto Condensed"
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }

    Rectangle {
        id: harvestBar
        anchors.left: growBar.right
        width: daysDelta(beginHarvestDate, endHarvestDate) / 365 * 12 * monthWidth
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Material.color(Material.Green, Material.Shade700)
        Label {
            text: formatDate(beginHarvestDate)
            font.family: "Roboto Condensed"
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }
}
