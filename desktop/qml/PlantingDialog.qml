import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Dialog {
    id: dialog
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string mode: "add"
    property string plantingIds: ""

    title: mode == "add" ? qsTr("Add planting(s)") : qsTr("Edit planting(s)")


    ScrollView {
        anchors.fill: parent

        PlantingForm {
        }
    }
}

