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
    property string crop: Planting.cropName(plantingId)
    property string variety: Planting.varietyName(plantingId)
    property date sowingDate: Planting.sowingDate(plantingId)
    property date endHarvestDate: Planting.endHarvestDate(plantingId)
    property int year
    property int length: Planting.totalLength(plantingId)
    property var locations: Location.locations(plantingId)
    property bool showOnlyDates: false

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    function cropName(plantingId) {
        var map = Planting.mapFromId("planting_view", plantingId);
        return map['crop']
    }

    function varietyName(plantingId) {
        var map = Planting.mapFromId("planting_view", plantingId);
        return map['variety']
    }

    Settings {
        id: settings
        property bool useStandardBedLength
        property int standardBedLength
    }

    Column {
        id: column
        Text {
            text: validId ? "%1, %2".arg(crop).arg(variety) : " "
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
        }
        Text {
            text: {
                if (!validId)
                    return "";

                var txt = qsTr("%1 − %2").arg(MDate.formatDate(sowingDate, year))
                                         .arg(MDate.formatDate(endHarvestDate, year))

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
        }
    }
}
