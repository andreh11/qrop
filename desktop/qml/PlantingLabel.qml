import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Item {
    id: control

    property int plantingId
    readonly property bool validId: plantingId > 0
    property var map: Planting.mapFromId("planting_view", plantingId)
    property string crop: map['crop']
    property string variety: map['variety']
    property date sowingDate: map['sowing_date']
    property date endHarvestDate: map['end_harvest_date']
    property int rank: map['planting_rank']
    property int year
    property var locations
    property double length
    property bool showOnlyDates: false
    property bool showRank: false

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    Settings {
        id: settings
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
    }

    Column {
        id: column
        Text {
            text: validId ? "%1, %2".arg(crop).arg(variety) : " "
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
            elide: Text.ElideRight
        }
        Text {
            text: {
                if (!validId)
                    return "";

                var txt = ""

                if (showRank && settings.showPlantingSuccessionNumber) {
                    txt += "#%1 ".arg(rank)
                }

                txt += qsTr("%1−%2").arg(MDate.formatDate(sowingDate, year)).arg(MDate.formatDate(endHarvestDate, year))

                if (!showOnlyDates) {
                    if (settings.useStandardBedLength) {
                        var beds = length/settings.standardBedLength
                        txt += qsTr(" ⋅ %L1 bed ⋅ %2", "", beds).arg(beds).arg(Location.fullName(locations))
                    } else {
                        txt += qsTr(" ⋅ %L1 bed m ⋅ %2").arg(length).arg(Location.fullName(locations))
                    }
                }
                return txt;
            }
            font.family: "Roboto Regular"
            color: Material.color(Material.Grey, Material.Shade600)
            font.pixelSize: Units.fontSizeCaption
            elide: Text.ElideRight
        }
    }
}
