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

    Material.elevation: 0
    Material.background: Units.pageColor
    padding: 0
    anchors.fill: parent

    Pane {
        id: backgroundPane
        Material.background: "white"
        Material.elevation: 2
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: paneWidth
    }

    ListView {
        id: unitView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors.fill: parent

        header: RowLayout {
            id: rowLayout
            spacing: Units.smallSpacing
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter

            ToolButton {
                id: backButton
                text: "\ue5c4"
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: pane.close()
                Layout.leftMargin: Units.formSpacing
            }

            Label {
                id: label
                text: qsTr("Units")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeSubheading
                Layout.fillWidth: true
            }

            FlatButton {
                text: qsTr("Add")
                highlighted: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Units.mediumSpacing

                onClicked: addUnitDialog.open()

                AddUnitDialog {
                    id: addUnitDialog
                    onAccepted: {
                        Unit.add({"fullname" : unitName,
                                     "abbreviation": unitAbbreviation});
                        unitModel.refresh();
                    }
                }
            }
        }

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()


        ScrollBar.vertical: ScrollBar {
            parent: pane
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        }
        cacheBuffer: Units.rowHeight * 20

        spacing: Units.smallSpacing
        model: UnitModel { id: unitModel }
        delegate: MouseArea {
            id: mouseArea
            height: Units.listSingleLineHeight
            width: paneWidth
            hoverEnabled: true
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                id: headerRow
                anchors.fill: parent
                spacing: Units.formSpacing

                EditableLabel {
                    text: fullname
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.fillHeight: true
                    onEditingFinished: {
                        Unit.update(unit_id, {"fullname": text})
                        unitModel.refresh();
                    }
                }

                EditableLabel {
                    text: abbreviation
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onEditingFinished: {
                        Unit.update(unit_id, {"abbreviation": text})
                        unitModel.refresh();
                    }
                }

                MyToolButton {
                    visible: mouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove unit")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: Units.mediumSpacing

                    onClicked: deleteDialog.open()

                    Dialog {
                        id: deleteDialog
                        title: qsTr("Delete %1?").arg(fullname)
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        onAccepted: {
                            Unit.remove(unit_id)
                            unitModel.refresh();
                        }

                        onRejected: deleteDialog.close()
                    }
                }
            }

            ThinDivider { width: parent.width; anchors.top: headerRow.bottom }
        }
    }
}
