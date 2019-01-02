import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.croplan.components 1.0

Pane {
    id: pane

    property int firstColumnWidth: 200
    property int secondColumnWidth: 150

    signal close();

    Material.elevation: 2
    Material.background: "white"
    padding: 0

    RowLayout {
        id: rowLayout
        spacing: Units.smallSpacing
        width: parent.width

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

        Button {
            text: qsTr("Add type")
            flat: true
            Material.foreground: Material.accent
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Units.mediumSpacing

            onClicked: addTypeDialog.open()

            SimpleAddDialog {
                id: addTypeDialog
                title: qsTr("Add type")
                labelText: "Type"

                onAccepted: {
                    TaskType.add({"type" : text})

                    taskTypeModel.refresh();
                }
            }
        }
    }

    ListView {
        id: taskTypeView
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: TaskTypeModel {
            id: taskTypeModel
            showPlantingTasks: false
        }

        delegate: SettingsTaskTypeDelegate {
            width: parent.width
            onRefresh: taskTypeModel.refresh()
            firstColumnWidth: pane.firstColumnWidth
            secondColumnWidth: pane.secondColumnWidth
        }
    }
}
