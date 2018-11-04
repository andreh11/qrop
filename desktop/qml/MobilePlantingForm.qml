import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.2
import Qt.labs.settings 1.0

import io.croplan.components 1.0
import "date.js" as MDate

Page {
    id: mobilePlantingForme
    
    function setFocus() {
        plantingFormHeader.cropField.contentItem.forceActiveFocus();
        plantingFormHeader.cropField.popup.open();
    }
    
    title: qsTr("Add plantings")
    Material.background: "white"
    
    header: PlantingFormHeader {
        id: plantingFormHeader
        estimatedRevenue: mobilePlantingForm.estimatedRevenue
        estimatedYield: mobilePlantingForm.estimatedYield
        unitText: mobilePlantingForm.unitText
        
        onCropSelected: {
            mobilePlantingForm.varietyField.forceActiveFocus();
            mobilePlantingForm.varietyField.popup.open()
        }
        
        onNewCropAdded: {
            mobilePlantingForm.varietyField.forceActiveFocus();
            mobilePlantingForm.addVarietyDialog.open();
        }
    }

    PlantingForm {
        id: mobilePlantingForm
        anchors.fill: parent
        anchors.margins: 16
        cropFieldIndex: plantingFormHeader.currentIndex
    }
}
