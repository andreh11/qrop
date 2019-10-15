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
        keywordModel.refresh();
    }

    Material.elevation: 2
    Material.background: Units.pageColor
    padding: 0
    anchors.fill: parent

    Pane {
        id: backgroundPane
        Material.background: "white"
        Material.elevation: 1
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: paneWidth
    }

    ListView {
        id: familyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors.fill: parent
        clip: true

        ScrollBar.vertical: ScrollBar {
            parent: pane
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        }
        cacheBuffer: Units.rowHeight * 20

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
                text: qsTr("Keywords")
                font.family: "Roboto Regular"
                font.pixelSize: Units.fontSizeBodyAndButton
                Layout.fillWidth: true
            }

            FlatButton {
                text: qsTr("Add")
                highlighted: true
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Units.mediumSpacing

                onClicked: addKeywordDialog.open()

                SimpleAddDialog {
                    id: addKeywordDialog
                    title: qsTr("Add keyword")

                    onAccepted: {
                        Keyword.add({"keyword" : text});
                        keywordModel.refresh();
                    }
                }
            }
        }

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()

        spacing: Units.smallSpacing
        model: KeywordModel { id: keywordModel }
        delegate: MouseArea {
            id: familyMouseArea
            height: Units.listSingleLineHeight
            width: paneWidth
            hoverEnabled: true
            anchors.horizontalCenter: parent.horizontalCenter

            RowLayout {
                id: headerRow
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Units.listSingleLineHeight
                spacing: Units.formSpacing

                EditableLabel {
                    id: editableLabel
                    text: model.keyword
                    Layout.leftMargin: Units.mediumSpacing
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.maximumWidth: Layout.minimumWidth
                    Layout.fillHeight: true
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
