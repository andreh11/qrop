import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Pane {
    id: pane

    property int firstColumnWidth: 200
    property int secondColumnWidth: 150
    property int paneWidth

    signal close();

    function refresh() {
        taskTypeModel.refresh();
    }

    Material.elevation: 2
    Material.background: Units.pageColor
    padding: 0

    Pane {
        id: backgroundPane
        Material.background: "white"
        Material.elevation: 1
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: paneWidth
    }

    ListView {
        id: taskTypeView
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        ScrollBar.vertical: ScrollBar {
            parent: pane
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        }
        cacheBuffer: Units.rowHeight * 20

        anchors.fill: parent
        model: TaskTypeModel {
            id: taskTypeModel
            showPlantingTasks: false
        }
        header: RowLayout {
            id: rowLayout
            spacing: Units.smallSpacing
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter

            ToolButton {
                id: drawerButton
                text: "\ue5c4"
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: pane.close()
                Layout.leftMargin: Units.formSpacing
            }

            Label {
                id: familyLabel
                text: qsTr("Task types")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeSubheading
                Layout.fillWidth: true
            }

            FlatButton {
                text: qsTr("Add type")
                highlighted: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Units.mediumSpacing

                onClicked: addTypeDialog.open()

                SimpleAddDialog {
                    id: addTypeDialog
                    title: qsTr("Add type")

                    onAccepted: {
                        TaskType.add({"type" : text})

                        taskTypeModel.refresh();
                    }
                }
            }
        }

        delegate: SettingsTaskTypeDelegate {
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter
            onRefresh: { taskTypeModel.refreshRow(index); taskTypeModel.resetFilter() }
            firstColumnWidth: pane.firstColumnWidth
            secondColumnWidth: pane.secondColumnWidth
        }
    }
}
