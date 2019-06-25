import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Column {
    id: locationColumn

    property alias treeViewWidth: locationView.treeViewWidth
    property bool chooseLocationMode
    property bool standardBedLength
    property bool useStandardBedLength
    property real plantingLength

    property date plantingDate
    property date endHarvestDate

    property real assignedLength: locationView.assignedLength()
    readonly property real remainingLength: plantingLength - assignedLength
    readonly property var selectedLocationIds: locationView.selectLocationIds();
    readonly property alias selectedIndexes: locationView.selectedIndexes

    signal exitSelectionMode()

    function reload()
    {
        locationView.reload();
    }
    
    function clearSelection()
    {
        locationView.clearSelection();
    }

    function selectLocationIds(ids)
    {
        locationView.selectLocationIds(ids);
    }

    RowLayout {
//        visible: chooseLocationMode
        width: parent.width
        
        Label {
            Layout.fillWidth: true
            text: settings.useStandardBedLength
                  ? qsTr("Remaining beds: %L1").arg(remainingLength/standardBedLength)
                  : qsTr("Remaining length: %L1 m", "", remainingLength).arg(remainingLength)
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeBodyAndButton
        }

        Button {
            text: qsTr("Unassign all beds")
            onClicked: {
                var plantingId = locationView.editedPlantingId;
                locationView.clearSelection();
                locationView.editedPlantingId = plantingId;
            }
            flat: true
        }
        
        Button {
            text: qsTr("Close")
            flat: true
            onClicked: exitSelectionMode()
            Material.foreground: Material.accent
        }
    }
    
    LocationView {
        id: locationView
//        visible: chooseLocationMode
        clip: true
        
        season: MDate.season(plantingDate)
        year: MDate.seasonYear(plantingDate)
        //                    width: parent.width
        //                    height: 400
        height: treeViewHeight + headerHeight
        width: treeViewWidth
        plantingEditMode: true
        
        editedPlantingLength: plantingLength
        editedPlantingPlantingDate: plantingDate
        editedPlantingEndHarvestDate: endHarvestDate

        onSelectedIndexesChanged: locationsModified = true
        onAddPlantingLength: {
            if (settings.useStandardBedLength)
                plantingAmountField.text = Number(plantingAmountField.text) + (length/standardBedLength)
            else
                plantingAmountField.text = plantingLength + length
            plantingAmountField.manuallyModified = true // for editedValues()
        }
    }
}
