import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Rectangle {
    id: delegate
    color: "white"
    radius: 2
    
    property var idList: model.plantings.split(",")
    property int firstId: Number(idList[0])
    
    height: summaryRow.height + detailsRow.height
    Rectangle {
        id: taskButtonRectangle
        height: Units.rowHeight
        width: childrenRect.width
        color: "white"
        anchors {
            top: parent.top
            right: parent.right
        }
        
        Row {
            spacing: -16
            anchors.verticalCenter: parent.verticalCenter
            ToolButton {
                text: "-7"
                visible: !model.done
                font.family: "Roboto Condensed"
                anchors.verticalCenter: parent.verticalCenter
                Material.foreground: Material.color(Material.Grey, Material.Shade700)
                onClicked: {
                    Task.delay(model.task_id, -1);
                    refresh();
                }
                
            }
            
            ToolButton {
                text: "+7"
                visible: !model.done
                font.family: "Roboto Condensed"
                anchors.verticalCenter: parent.verticalCenter
                Material.foreground: Material.color(Material.Grey, Material.Shade700)
                onClicked: {
                    Task.delay(model.task_id, 1);
                    refresh();
                }
            }
            
            ToolButton {
                text: enabled ? "\ue872" : ""
                Material.foreground: Material.color(Material.Grey, Material.Shade700)
                font.family: "Material Icons"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                enabled: model.task_type_id > 3
                hoverEnabled: true
                onClicked: {
                    Task.remove(model.task_id);
                    refresh();
                }
                
                ToolTip.text: qsTr("Cannot remove a sow/plant task. Switch to crop plan to remove the related planting.")
                ToolTip.visible: hovered && !enabled
            }
        }
    }
    
    Column {
        id: mainColumn
        width: parent.width
        
        Row {
            id: summaryRow
            height: Units.rowHeight
            spacing: Units.smallSpacing
            leftPadding: Units.smallSpacing
            
            TaskCompleteButton {
                id: completeButton
                anchors.verticalCenter: parent.verticalCenter
                height: width
                width: parent.height
                overdue: model.overdue
                done: model.done
                due: model.due
                onClicked: {
                    if (done)
                        Task.uncompleteTask(model.task_id);
                    else
                        Task.completeTask(model.task_id);
                    taskModel.refresh();
                }
                onPressAndHold: {
                    popup.x = completeButton.x
                    popup.y = completeButton.y
                    popup.open()
                }
            }
            
            Row {
                width: tableHeaderModel[0].width
                anchors.verticalCenter: parent.verticalCenter
                PlantingLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    plantingId: firstId
                    showOnlyDates: true
                    sowingDate: Planting.sowingDate(plantingId)
                    endHarvestDate: Planting.endHarvestDate(plantingId)
                    year: page.year
                }
                
                ToolButton {
                    id: detailsButton
                    text: "⋅⋅⋅"
                    //                                flat: true
                    checkable: true
                    visible: idList.length > 1
                    ToolTip.visible: hovered
                    ToolTip.text: checked ? qsTr("Hide plantings and locations details")
                                          : qsTr("Show plantings and locations details")
                }
            }
            
            TableLabel {
                text: model.locations
                elide: Text.ElideRight
                width: tableHeaderModel[1].width
                anchors.verticalCenter: parent.verticalCenter
            }
            
            //                        TableLabel {
            //                            text: model.type
            //                            elide: Text.ElideRight
            //                            width: tableHeaderModel[0].width
            //                            anchors.verticalCenter: parent.verticalCenter
            //                        }
            
            TableLabel {
                text: {
                    var planting_ids = model.plantings.split(',')
                    var planting_id = Number(planting_ids[0])
                    var map = Planting.mapFromId("planting_view", planting_id);
                    var length = map['length']
                    var rows = map['rows']
                    var spacingPlants = map['spacing_plants']
                    
                    if (task_type_id === 1 || task_type_id === 3) {
                        return "%1 bed m, %2 X %3 cm".arg(length).arg(rows).arg(spacingPlants)
                    } else if (task_type_id === 2) {
                        return qsTr("%L1 trays of  %L2").arg(map["trays_to_start"]).arg(map['tray_size'])
                    } else {
                        return qsTr("%1%2%3").arg(model.method).arg(model.implement ? ", " : "").arg(model.implement)
                    }
                    
                }
                
                elide: Text.ElideRight
                width: tableHeaderModel[2].width
                anchors.verticalCenter: parent.verticalCenter
            }
            
            TableLabel {
                text: NDate.formatDate(model.assigned_date, year, "")
                elide: Text.ElideRight
                width: tableHeaderModel[3].width
                anchors.verticalCenter: parent.verticalCenter
            }
            
        }
        
        Column {
            id: detailsRow
            visible: detailsButton.checked
            width: parent.width
            height: detailsButton.checked ? (idList.length - 1) * Units.rowHeight : 0
            Repeater {
                model: idList.slice(1)
                
                Row {
                    height: Units.rowHeight
                    spacing: Units.smallSpacing
                    leftPadding: Units.smallSpacing
                    Item { width: parent.height; height: width }
                    PlantingLabel {
                        plantingId: Number(modelData)
                        year: page.year
                        sowingDate: Planting.sowingDate(plantingId)
                        endHarvestDate: Planting.endHarvestDate(plantingId)
                        showOnlyDates: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
