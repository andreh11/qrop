import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtCharts 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Frame {
    id: taskSideSheet

    property alias year: plantingTaskView.year
    property alias week: plantingTaskView.week
    property alias plantingIdList: plantingTaskTemplateView.plantingIdList

    signal taskDateModified

    function refresh() {
        plantingTaskView.refresh();
        plantingTaskTemplateView.refresh();
    }

    Material.elevation: 0
    padding: 0

    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.12) // From Material guidelines
        width: 1
    }

    RowLayout {
        id: header
        anchors {
            top: parent.top
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
            color: Units.colorHighEmphasis
        }

        ToolButton {
            text: "\ue14c"
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: taskSideSheet.visible = false;
            Layout.rightMargin: -padding
            Material.foreground: Qt.rgba(0.459, 0.459, 0.459)
        }
    }

    BlankLabel {
        visible: plantingIdList.length <= 0
        anchors.centerIn: parent
        width: parent.width - Units.formSpacing * 2
        primaryText: qsTr("No planting selected")
        secondaryText: qsTr("Please select at least one planting")
    }

    ColumnLayout {
        visible: plantingIdList.length > 0
        anchors {
            top: parent.top
            topMargin: 64
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 0
        }

        PlantingTaskView {
            id: plantingTaskView
            visible: plantingIdList.length === 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            taskTemplateId: plantingTaskTemplateView.taskTemplateId
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
            plantingId: visible ? plantingIdList[0] : -1
            onTaskDateModified: taskSideSheet.taskDateModified();
        }

        Item {
            visible: plantingIdList.length > 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            BlankLabel {
                anchors.centerIn: parent
                primaryText: qsTr("Several plantings selected")
                secondaryText: qsTr("Select templates to bulk apply")
            }
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
            Layout.leftMargin: 1
            Layout.preferredHeight: parent.height/3
            onTemplateListChanged: plantingTaskView.refresh();
        }
    }
}
