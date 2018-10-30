import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Dialog {
    id: dialog
    modal: true
    focus: true

    property var model
    property string mode: "add"
    property string plantingIds: ""
    property bool formAccepted: plantingForm.accepted
    property alias plantingForm: plantingForm

    function createPlanting() {
        dialog.title = qsTr("Add planting(s)")
        dialog.open()
    }

    function editPlantings(plantingIds) {
        dialog.title = qsTr("Edit planting(s)")
        dialog.open()
    }

    footer: Item {
        width: parent.width
        height: childrenRect.height
        Button {
            id: cancelButton
            flat: true
            text: qsTr("Cancel")
            anchors.right: applyButton.left
            anchors.rightMargin: Units.smallSpacing
            onClicked: dialog.reject();
            Material.foreground: Material.accent
        }

        Button {
            id: applyButton
            Material.foreground: Material.accent
            anchors.right: parent.right
            anchors.rightMargin: Units.smallSpacing
            flat: true
            text: mode === "add" ? qsTr("Add") : qsTr("Edit")
            enabled: formAccepted
            onClicked: dialog.accept();
        }
    }

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
        plantingForm.cropField.contentItem.forceActiveFocus();
        plantingForm.cropField.popup.open();
    }

    onAccepted: {
        Planting.addSuccessions(plantingForm.successions,
                                plantingForm.weeksBetween, plantingForm.values);
        model.refresh();
    }
}
