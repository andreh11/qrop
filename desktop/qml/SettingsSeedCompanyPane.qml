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
    
    signal close();
    
    Material.elevation: 2
    Material.background: "white"
    padding: 0
    
    RowLayout {
        id: rowLayout
        spacing: Units.smallSpacing
        width: parent.width
        
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
            text: qsTr("Seeds companies")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeSubheading
            Layout.fillWidth: true
        }
        
        Button {
            text: qsTr("Add seed company")
            flat: true
            Material.foreground: Material.accent
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
    
    ListView {
        id: seedCompanyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: scrollBar }

        spacing: Units.smallSpacing
        model: SeedCompanyModel { id: seedCompanyModel }
        delegate: MouseArea {
            id: mouseArea
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
                    text: seed_company
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    Layout.minimumWidth: pane.firstColumnWidth
                    Layout.leftMargin: Units.mediumSpacing
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
        }
    }
}
