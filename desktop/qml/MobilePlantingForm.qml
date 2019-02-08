import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0
import "date.js" as MDate

Page {
    id: mobilePlantingForme
    
    function setFocus() {
        plantingFormHeader.cropField.contentItem.forceActiveFocus();
        plantingFormHeader.cropField.popup.open();
    }
    
    title: qsTr("Add plantings")
    Material.background: Material.color(Material.Grey, Material.Shade100)

    header: PlantingFormHeader {
        id: plantingFormHeader
        estimatedRevenue: plantingForm.estimatedRevenue
        estimatedYield: plantingForm.estimatedYield
        unitText: plantingForm.unitText
        onCropSelected: {
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.cropId = cropId;
            plantingForm.varietyField.popup.open();
        }

        onNewCropAdded: {
            plantingForm.cropId = newCropId;
            plantingForm.varietyField.forceActiveFocus();
            plantingForm.addVarietyDialog.open();
        }
    }

    PlantingForm {
        id: plantingForm
        anchors.fill: parent
        anchors.margins: 16
        cropId: plantingFormHeader.cropId
    }
}
