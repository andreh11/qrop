import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtCharts 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Pane {
    id: taskSideSheet

    property alias year: plantingTaskView.year
    property alias week: plantingTaskView.week
    property alias plantingId: plantingTaskView.plantingId


    function refresh() {
        plantingTaskView.refresh();
        plantingTaskTemplateView.refresh();
    }
    padding: 0

    width: visible ? 320 : 0
//    edge: Qt.RightEdge
//    modal: false
    Material.elevation: 0
//    closePolicy: Popup.NoAutoClose
//    dragMargin: 0

    RowLayout {
        id: header

        anchors {
            top: parent.top
            topMargin: 16
            left: parent.left
            right: parent.right
            leftMargin: 16
            rightMargin: 16
        }

        Label {
            text: qsTr("Tasks")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeTitle
            Layout.fillWidth: true
        }

        ToolButton {
            text: "\ue14c"
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: taskSideSheet.visible = false;
            Layout.rightMargin: -padding
        }
    }

    Column {
        visible: plantingId <= 0
        anchors.centerIn: parent
        Label {
            text: qsTr("No planting selected")
            color: Units.colorHighEmphasis
            font.pixelSize: Units.fontSizeTitle
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter

        }
        Label {
            text: qsTr("Please select at least one planting")
            color: Units.colorMediumEmphasis
            font.pixelSize: Units.fontSizeSubheading
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }


    ColumnLayout {
        visible: plantingId > 0
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 0
        }

        PlantingTaskView {
            id: plantingTaskView
            Layout.fillWidth: true
            Layout.fillHeight: true
            taskTemplateId: plantingTaskTemplateView.taskTemplateId
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
        }
        
        ThinDivider {
            Layout.fillWidth: true
        }
        
        Label {
            text: qsTr("Templates")
            font.family: "Roboto Regular"
            color: Qt.rgba(0, 0, 0, 0.6)
            font.pixelSize: Units.fontSizeSubheading
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 16
        }
        
        PlantingTaskTemplateView {
            id: plantingTaskTemplateView
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height/3
            plantingId: plantingTaskView.plantingId
            onTemplateListChanged: plantingTaskView.refresh();
        }
    }
}
