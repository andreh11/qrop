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
    focus: true

    property var model
    property string mode: "add"
    property string plantingIds: ""

    title: mode == "add" ? qsTr("Add planting(s)") : qsTr("Edit planting(s)")

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        Keys.onUpPressed: verticalScrollBar.decrease()
        Keys.onDownPressed: verticalScrollBar.increase()

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollBar
            visible: largeDisplay
            parent: scrollView.parent
            anchors.top: scrollView.top
            anchors.left: scrollView.right
            anchors.leftMargin: 4
            anchors.bottom: scrollView.bottom
        }

        PlantingForm {
            id: plantingForm
            anchors.fill: parent
            focus: true
        }
    }

    onOpened: {
        plantingForm.cropField.editText= "";
        plantingForm.cropField.forceActiveFocus()
    }

    onAccepted: {
        Planting.addSuccessions(plantingForm.successions,
                                plantingForm.weeksBetween, plantingForm.values)
        plantingModel.refresh()
    }
}
