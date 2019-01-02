import QtQuick 2.12
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
            text: qsTr("Families and crops")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeSubheading
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Add family")
            flat: true
            Material.foreground: Material.accent
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

        }

        Button {
            text: qsTr("Add crop")
            flat: true
            Material.foreground: Material.accent
            onClicked: addCropDialog.open();
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Units.formSpacing

            AddCropDialog {
                id: addCropDialog
            }
        }
    }

    ListView {
        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: Units.smallSpacing
        model: FamilyModel { id: familyModel }
        delegate: familyDelegate
    }

    Component {
        id: familyDelegate
        Column {
            width: parent.width

            Rectangle {
                color: Material.color(Material.Grey, Material.Shade100)
                width: parent.width
                height: childrenRect.height

                MouseArea {
                    id: familyMouseArea
                    height: Units.rowHeight
                    width: parent.width
                    hoverEnabled: true

                    RowLayout {
                        id: headerRow
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: Units.rowHeight
                        spacing: Units.formSpacing

                        TextCheckBox {
                            id: headerCheckbox
                            text: family
                            selectionMode: false
                            color: model.color
                            Layout.preferredWidth: Units.rowHeight * 0.8
                            round: true
                            MouseArea {
                                anchors.fill: parent
                            }
                            Layout.leftMargin: Units.mediumSpacing
                        }

                        TextInput {
                            text: family
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            Layout.minimumWidth: pane.firstColumnWidth
                            onEditingFinished: {
                                Family.update(family_id, {"family": text})
                                familyModel.refresh();
                            }

                        }

                        ComboBox {
                            flat: true
                            model: 10
                            Layout.minimumWidth: pane.secondColumnWidth
                            currentIndex: interval
                            font.family: "Roboto Regular"
                            font.pixelSize: Units.fontSizeBodyAndButton
                            displayText: qsTr("%L1 years", "", currentIndex).arg(currentIndex)
                            onCurrentIndexChanged: Family.update(family_id, {"interval": currentIndex})

                            ToolTip.text: qsTr("Minimum rotation interval for %1").arg(family)
                            ToolTip.visible: hovered
                            ToolTip.delay: 200
                        }


                        Item { Layout.fillWidth: true }

                        MyToolButton {
                            visible: familyMouseArea.containsMouse
                            text: enabled ? "\ue872" : ""
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            ToolTip.text: qsTr("Remove family")
                            ToolTip.visible: hovered
                            ToolTip.delay: 200
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                            onClicked: confirmFamilyDeleteDialog.open()

                            Dialog {
                                id: confirmFamilyDeleteDialog
                                title: qsTr("Delete %1?").arg(family)
                                standardButtons: Dialog.Ok | Dialog.Cancel

                                Text {
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    text: qsTr("All crops and plantings will be lost.")
                                }

                                onAccepted: {
                                    Family.remove(family_id)
                                    familyModel.refresh();
                                }

                                onRejected: confirmFamilyDeleteDialog.close()
                            }
                        }

                        MyToolButton {
                            id: showCropsButton
                            Layout.leftMargin: -28
                            Layout.rightMargin: Units.mediumSpacing
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            checkable: true
                            text: checked ?  "\ue313" : "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            ToolTip.text: checked ? qsTr("Hide crops") : qsTr("Show crop")
                            ToolTip.visible: hovered
                            ToolTip.delay: 200
                        }
                    }
                }
            }

            ListView {
                spacing: 0
                visible: showCropsButton.checked
                width: parent.width
                height: contentHeight

                model: CropModel {
                    id: cropModel
                    familyId: family_id
                }

                delegate: cropDelegate
            }

        }
    }

    Component {
        id: cropDelegate
        Column {
            width: parent.width

            Rectangle {
                id: delegate
                height: childrenRect.height
                width: parent.width

                MouseArea {
                    id: cropMouseArea
                    height: Units.rowHeight
                    width: parent.width
                    hoverEnabled: true

                    RowLayout {
                        id: cropRow
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: Units.rowHeight
                        spacing: Units.formSpacing

                        TextCheckBox {
                            id: checkBox
                            text: model.crop
                            selectionMode: false
                            Layout.leftMargin: Units.mediumSpacing
                            //                                width: 24
                            Layout.preferredWidth: Units.rowHeight * 0.8
                            round: true
                            color: model.color
                        }

                        TextInput {
                            text: model.crop
                            font.family: "Roboto Regular"
                            Layout.minimumWidth: pane.firstColumnWidth
                            onEditingFinished: {
                                Crop.update(model.crop_id, {"crop": text});
                                model.refresh();
                            }
                        }

                        Item { height: 1; Layout.fillWidth: true }

                        MyToolButton {
                            visible: cropMouseArea.containsMouse
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            text: enabled ? "\ue872" : ""
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            ToolTip.text: qsTr("Remove crop")
                            ToolTip.visible: hovered
                            ToolTip.delay: 200

                            onClicked: confirmCropDeleteDialog.open()

                            Dialog {
                                id: confirmCropDeleteDialog
                                title: qsTr("Delete %1?").arg(model.crop)
                                standardButtons: Dialog.Ok | Dialog.Cancel

                                Text {
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    text: qsTr("All plantings will be lost.")
                                }

                                onAccepted: {
                                    Crop.remove(model.crop_id)
                                    cropModel.refresh();
                                }

                                onRejected: confirmCropDeleteDialog.close()
                            }
                        }

                        MyToolButton {
                            id: showVarietiesButton
                            Layout.leftMargin: -28
                            Layout.rightMargin: Units.mediumSpacing
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            checkable: true
                            text: checked ?  "\ue313" : "\ue315"
                            font.family: "Material Icons"
                            font.pixelSize: 22
                            ToolTip.text: checked ? qsTr("Hide varieties") : qsTr("Show varieties")
                            ToolTip.visible: hovered
                            ToolTip.delay: 200
                        }
                    }

                }
            }

            ListView {
                spacing: 0
                visible: showVarietiesButton.checked
                width: parent.width
                height: contentHeight

                model: VarietyModel {
                    id: cropModel
                    cropId: crop_id
                }

                delegate: varietyDelegate
            }

            Button {
                visible: showVarietiesButton.checked
                id: addVarietyButton
                anchors.right: parent.right
                anchors.rightMargin: Units.mediumSpacing
                flat: true
                text: qsTr("Add variety")
                onClicked: addVarietyDialog.open();

                AddVarietyDialog {
                    id: addVarietyDialog
                    onAccepted: {
                        if (seedCompanyId > 0)
                            Variety.add({"variety" : varietyName,
                                            "crop_id" : model.crop_id,
                                            "seed_company_id" : seedCompanyId});
                        else
                            Variety.add({"variety" : varietyName,
                                            "crop_id" : model.crop_id});

                        model.refresh();
                    }
                }
            }
        }
    }

    Component {
        id: varietyDelegate
        Column {
            width: parent.width

            Rectangle {
                height: childrenRect.height
                width: parent.width

                MouseArea {
                    id: varietyMouseArea
                    height: Units.rowHeight
                    width: parent.width
                    hoverEnabled: true

                    RowLayout {
                        id: varietyRow
                        height: Units.rowHeight
                        width: parent.width
                        spacing: Units.formSpacing

                        TextInput {
                            text: model.variety
                            color: Qt.rgba(0, 0, 0, 0.7)
                            font.family: "Roboto Regular"
                            Layout.leftMargin: Units.mediumSpacing + Units.formSpacing + Units.rowHeight * 0.8
                            Layout.minimumWidth: pane.firstColumnWidth

                            onEditingFinished: Variety.update(model.variety_id,
                                                              {"variety": text})
                        }

                        // BUG: this shouldb a MyComboBox, but this one seems to buggy; the height
                        // of the Popup isn't always correct.
                        ComboBox {
                            id: seedCompanyField

                            property int rowId: seed_company_id

                            function setRowId(rowId) {
                                var i = 0;
                                while (model.rowId(i) !== rowId && i < model.rowCount)
                                    i++;
                                if (i < model.rowCount)
                                    currentIndex = i;
                            }

                            onRowIdChanged: setRowId(rowId)
                            flat: true
                            Layout.minimumWidth: pane.secondColumnWidth
                            model: SeedCompanyModel {
                                id: seedCompanyModel
                            }
                            textRole: "seed_company"

                            onCurrentIndexChanged: {
                                var companyId = seedCompanyModel.rowId(seedCompanyField.currentIndex)
                                Variety.update(variety_id, {"seed_company_id": companyId})
                            }
                        }

                        Item { height: 1; Layout.fillWidth: true }

                        MyToolButton {
                            height: parent.height * 0.8
                            visible: varietyMouseArea.containsMouse
                            text: enabled ? "\ue872" : ""
                            font.family: "Material Icons"
                            font.pixelSize: 22

                            ToolTip.text: qsTr("Remove variety")
                            ToolTip.visible: hovered
                            ToolTip.delay: 200

                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            Layout.rightMargin: Units.formSpacing

                            onClicked: confirmVarietyDeleteDialog.open()

                            Dialog {
                                id: confirmVarietyDeleteDialog
                                title: qsTr("Delete %1?").arg(model.variety)
                                standardButtons: Dialog.Ok | Dialog.Cancel

                                Text {
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    text: qsTr("All plantings will be lost.")
                                }

                                onAccepted: {
                                    Variety.remove(model.variety_id)
                                    varietyModel.refresh();
                                }

                                onRejected: confirmVarietyDeleteDialog.close()
                            }
                        }
                    }

                }
            }
        }
    }

}
