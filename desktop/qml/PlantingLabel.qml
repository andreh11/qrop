import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

import io.croplan.components 1.0

Item {
    id: control

    property int plantingId
    property string crop: cropName(plantingId)
    property string variety: varietyName(plantingId)
    property date sowingDate
    property date endHarvestDate
    property int year
    property int length
    property var locations
    property bool showOnlyDates: false

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    function cropName(id) {
        var map = Planting.mapFromId("planting_view", id);
        return map['crop']
    }

    function varietyName(id) {
        var map = Planting.mapFromId("planting_view", id);
        return map['variety']
    }

    Column {
        id: column
        Text {
            text: "%1, %2".arg(crop).arg(variety)
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
        }
        Text {
            text: showOnlyDates ? qsTr("%1 − %2").arg(NDate.formatDate(sowingDate, year)).arg(NDate.formatDate(endHarvestDate, year))
                                : qsTr("%1 − %2 ⋅ %3 bed m ⋅ %4").arg(NDate.formatDate(sowingDate, year)).arg(NDate.formatDate(endHarvestDate, year)).arg(length).arg(locations)
            font.family: "Roboto Regular"
            color: Material.color(Material.Grey, Material.Shade600)
            font.pixelSize: Units.fontSizeCaption
        }
}
}
