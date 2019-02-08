import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

Column {
    property int firstColumnWidth
    property int secondColumnWidth
    
    signal refresh()
    
    Rectangle {
        height: childrenRect.height
        width: parent.width
        
        MouseArea {
            id: mouseArea
            height: Units.rowHeight
            width: parent.width
            hoverEnabled: true
            
            RowLayout {
                id: varietyRow
                height: Units.rowHeight
                width: parent.width
                spacing: Units.formSpacing
                
                TextInput {
                    text: model.implement
                    color: Qt.rgba(0, 0, 0, 0.7)
                    font.family: "Roboto Regular"
                    Layout.leftMargin: Units.mediumSpacing * 2
                    Layout.minimumWidth: firstColumnWidth
                    
                    onEditingFinished: TaskImplement.update(model.task_implement_id, {"implement": text})
                }
                
                Item { height: 1; Layout.fillWidth: true }
                
                MyToolButton {
                    height: parent.height * 0.8
                    visible: mouseArea.containsMouse
                    text: enabled ? "\ue872" : ""
                    font.family: "Material Icons"
                    font.pixelSize: 22
                    
                    ToolTip.text: qsTr("Remove implement")
                    ToolTip.visible: hovered
                    ToolTip.delay: 200
                    
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: Units.formSpacing
                    
                    onClicked: deleteDialog.open()
                    
                    Dialog {
                        id: deleteDialog
                        title: qsTr("Delete %1?").arg(model.implement)
                        standardButtons: Dialog.Ok | Dialog.Cancel
                        
                        Text {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: qsTr("All related tasks will lose their implement.")
                        }
                        
                        onAccepted: {
                            TaskImplement.remove(model.task_implement_id)
                            refresh()
                        }
                        
                        onRejected: deleteDialog.close()
                    }
                }
            }
            
        }
    }
}
