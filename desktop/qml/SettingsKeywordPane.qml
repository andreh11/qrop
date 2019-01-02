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
            text: qsTr("Keywords")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeSubheading
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Add keyword")
            flat: true
            Material.foreground: Material.accent
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Units.mediumSpacing

            onClicked: addKeywordDialog.open()

            AddKeywordDialog {
                id: addKeywordDialog
                onAccepted: {
                    Keyword.add({"keyword" : keywordName});
                    keywordModel.refresh();
                }
            }
        }
    }

    ListView {
        id: familyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: Units.smallSpacing
        model: KeywordModel { id: keywordModel }
        delegate: MouseArea {
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

                TextInput {
                    text: keyword
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.fillWidth: true
                    onEditingFinished: {
                        Keyword.update(keyword_id, {"keyword": text})
                        keywordModel.refresh();
                    }
                }

                MyToolButton {
                    visible: familyMouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    ToolTip.text: qsTr("Remove keyword")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: Units.mediumSpacing

                    onClicked: confirmFamilyDeleteDialog.open()

                    Dialog {
                        id: confirmFamilyDeleteDialog
                        title: qsTr("Delete %1?").arg(keyword)
                        standardButtons: Dialog.Ok | Dialog.Cancel

                        onAccepted: {
                            Keyword.remove(keyword_id)
                            keywordModel.refresh();
                        }

                        onRejected: confirmFamilyDeleteDialog.close()
                    }
                }
            }
        }
    }
}
