import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Dialog {
    id: dialog
    modal: true
    title: "Add planting(s)"
    standardButtons: Dialog.Ok | Dialog.Cancel

    PlantingForm {
        anchors.fill: parent
    }
}

