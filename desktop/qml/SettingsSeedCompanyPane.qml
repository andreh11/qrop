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


    ButtonGroup {
        id: buttonGroup
    }

    ListView {
        id: seedCompanyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors.fill: parent

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()

        ScrollBar.vertical: ScrollBar {
            parent: pane
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        }
        cacheBuffer: Units.rowHeight * 20

        header:  RowLayout {
            id: rowLayout
            spacing: Units.smallSpacing
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter

            ToolButton {
                id: backButton
                text: "\ue5c4"
                font.family: "Material Icons"
                Material.foreground: Units.colorHighEmphasis
                font.pixelSize: Units.fontSizeHeadline
                onClicked: pane.close()
                Layout.leftMargin: Units.formSpacing
            }

            Label {
                id: label
                text: qsTr("Seeds companies")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                color: Units.colorHighEmphasis
                Layout.fillWidth: true
            }

            FlatButton {
                text: qsTr("Add")
                highlighted: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Units.mediumSpacing
                onClicked: addDialog.open()

                SimpleAddDialog {
                    id: addDialog
                    title: qsTr("Add a seed company")
                    onAccepted: {
                        SeedCompany.add({"seed_company" : text})
                        seedCompanyModel.refresh();
                    }
                }
            }
        }

        spacing: Units.smallSpacing
        model: SeedCompanyModel { id: seedCompanyModel }
        delegate: MouseArea {
            id: mouseArea
            height: Units.listSingleLineHeight
            width: paneWidth
            hoverEnabled: true
            onDoubleClicked: editableLabel.state = "edit"
            onClicked: seedCompanyView.currentIndex = index
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                id: headerRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: parent.height
                spacing: Units.formSpacing

                RadioButton {
                    autoExclusive: true
                    Layout.leftMargin: Units.mediumSpacing
                    ButtonGroup.group: buttonGroup
                    onCheckedChanged: SeedCompany.setDefault(model.seed_company_id, checked)
                    checked: model.is_default === 1
                }

                EditableLabel {
                    id: editableLabel
                    text: seed_company
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.fillWidth: true
                    onEditingFinished: {
                        SeedCompany.update(seed_company_id, {"seed_company": text})
                        seedCompanyModel.refresh();
                    }
                }


                MyToolButton {
                    visible: mouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove seed company")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: Units.mediumSpacing

                    onClicked: deleteDialog.open()

                    Dialog {
                        id: deleteDialog
                        title: qsTr("Delete %1?").arg(seed_company)
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        onAccepted: {
                            SeedCompany.remove(seed_company_id)
                            seedCompanyModel.refresh();
                        }

                        onRejected: deleteDialog.close()
                    }
                }
            }

            ThinDivider { width: parent.width; anchors.top: headerRow.bottom }
        }
    }
}
