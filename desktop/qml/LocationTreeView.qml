import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls.Styles 1.4 as Styles1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.10
import Qt.labs.settings 1.0

import io.croplan.components 1.0
import "date.js" as MDate

Controls1.TreeView {
    id: treeView
    //                anchors.fill: parent
    
    //                property int _scrollingDirection: {
    //                    var yCoord = treeView.mapFromItem(dragArea, 0, dragArea.mouseY).y;
    //                    if (yCoord < scrollEdgeSize) {
    //                        -1;
    //                    } else if (yCoord > _listView.height - scrollEdgeSize) {
    //                        1;
    //                    } else {
    //                        0;
    //                    }
    //                }
    
    // Size of the are of the bottom and top of TreeView where the drag-scrolling
    // happens.
    property int scrollEdgeSize: 6
    
    property int season
    property int year
    
    property bool plantingEditMode: false

    property int indentation: 20
    property int draggedPlantingId: -1
    property date plantingDate: Planting.plantingDate(draggedPlantingId)
    property date endHarvestDate: Planting.endHarvestDate(draggedPlantingId)
    readonly property date seasonBegin: MDate.seasonBeginning(season, year)
    
    property var expandIndex: null
    property var draggedOnIndex: null
    property alias expandTimer: expandTimer
    property ItemSelectionModel selectionModel
    property LocationModel locationModel

    property var colorList: [
        Material.color(Material.Yellow, Material.Shade100),
        Material.color(Material.Green, Material.Shade100),
        Material.color(Material.Blue, Material.Shade100),
        Material.color(Material.Pruple, Material.Shade100),
        Material.color(Material.Teal, Material.Shade100),
        Material.color(Material.Cyan, Material.Shade100)
    ]


    //                SmoothedAnimation {
    //                    id: upAnimation
    //                    target: treeView
    //                    property: "contentY"
    //                    to: 0
    //                    running: _scrollingDirection == 1
    //                }
    
    //                treeView.__listView.contentY.
    
    SmoothedAnimation {
        id: downAnimation
        target: treeView
        property: "height"
        to: 30
        running: true
    }
    
    Timer {
        id: expandTimer
        interval: 300
        onTriggered: {
            if (treeView.expandIndex && treeView.expandIndex === treeView.draggedOnIndex) {
                treeView.expand(treeView.expandIndex);
                treeView.draggedOnIndex = null;
            }
        }
    }
    
    frameVisible: false
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
    implicitWidth: headerRectangle.implicitWidth + 80
    
    Controls1.TableViewColumn {
        role: "name"
    }
    
    Rectangle {
        id: begLine
        visible: plantingEditMode ||  treeView.draggedPlantingId > 0
        // TODO: remove magic numbers
        x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2
           + Units.position(treeView.seasonBegin, plantingEditMode ? editedPlantingPlantingDate
                                                                   : treeView.plantingDate)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Material.color(Material.Green)
        z: 2
    }
    
    Rectangle {
        id: endLine
        visible: plantingEditMode || treeView.draggedPlantingId > 0
        // TODO: remove magic numbers
        x: 100 + 16 + Units.rowHeight * 0.8 + Units.smallSpacing * 2
           + Units.position(treeView.seasonBegin, plantingEditMode ? editedPlantingEndHarvestDate
                                                                   : treeView.endHarvestDate)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Material.color(Material.Green)
        z: 2
    }
    
    backgroundVisible: false
    headerDelegate: null
    style: Styles1.TreeViewStyle {
        id: treeViewStyle
        indentation: indentation
        rowDelegate: Rectangle {
            height: Units.rowHeight + 1
            color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                             selectionModel.isSelected(styleData.index) ? 1.1 :  1)
            
            ThinDivider {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
            }
        }
        
        branchDelegate:  Rectangle {
            id: branchRectangle
            color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                             selectionModel.isSelected(styleData.index) ? 1.1 :  1)
            width: indentation
            height: Units.rowHeight + 1
            x: - styleData.depth * indentation
            
            ThinDivider {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
            }
            
            Text {
                leftPadding: Units.smallSpacing
                anchors.centerIn: parent
                //                        width: 24
                text: styleData.hasChildren
                      ? (styleData.isExpanded ? "\ue313" : "\ue315")
                      : ""
                font { family: "Material Icons"; pixelSize: 22 }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    itemDelegate:  Column {
        property int locationId: locationModel.locationId(styleData.index)
        Rectangle {
            width: parent.width
            height: Units.rowHeight + 1
            color: Qt.darker(styleData.hasChildren ? colorList[styleData.depth] : "white",
                             selectionModel.isSelected(styleData.index) ? 1.1 :  1)
            
            //                        opacity: dropArea.containsDrag ? 1 : 0.8
            x: - styleData.depth * indentation
            
            DropArea {
                id: dropArea
                anchors.fill: parent
                
                onEntered: {
                    var list = drag.text.split(";")
                    var plantingId = Number(list[0])
                    var sourceLocationId = Number(list[1])
                    if (plantingId !== treeView.draggedPlantingId)
                        treeView.draggedPlantingId = plantingId;
                    
                    if (styleData.hasChildren) {
                        if (!styleData.isExpanded) {
                            treeView.expandIndex = styleData.index
                            treeView.draggedOnIndex = styleData.index
                            treeView.expandTimer.stop();
                            treeView.expandTimer.start();
                        }
                        drag.accepted = (styleData.depth >= locationModel.depth - 1)
                                && (sourceLocationId === -1);
                        
                    } else if (locationId !== sourceLocationId) {
                        drag.accepted = locationSettings.allowPlantingsConflict
                                || locationModel.acceptPlanting(styleData.index, plantingId);
                    } else {
                        drag.accepted = false;
                    }
                }
                
                onExited: {
                    treeView.draggedPlantingId = -1;
                    treeView.draggedOnIndex = null
                }
                
                onDropped: {
                    treeView.draggedPlantingId = -1
                    
                    if (//!styleData.hasChildren
                            drop.hasText
                            && drop.proposedAction == Qt.MoveAction) {
                        
                        var locationId = locationModel.locationId(styleData.index)
                        var list = drop.text.split(";")
                        var plantingId = Number(list[0])
                        var sourceLocationId = Number(list[1])
                        
                        //                                    if (!locationModel.rotationRespected(styleData.index, plantingId)) {
                        //                                        rotationSnackbar.open();
                        //                                    }
                        
                        drop.acceptProposedAction()
                        
                        var length = 0;
                        if (sourceLocationId > 0) // drag comes from location
                            length = Location.plantingLength(plantingId, sourceLocationId)
                        else
                            length = Planting.lengthToAssign(plantingId)
                        locationModel.addPlanting(styleData.index, plantingId, length)
                        
                        treeView.draggedOnIndex = null
                        treeView.expandIndex = null
                    }
                }
            }
            
            MouseArea {
                id: rowMouseArea
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: {
                    if (styleData.hasChildren || !locationView.plantingEditMode)
                        return;
                    if (!locationModel.acceptPlanting(styleData.index,
                                                      editedPlantingPlantingDate,
                                                      editedPlantingEndHarvestDate))
                        return;
                    
                    if (selectionModel.isSelected(styleData.index)) {
                        assignedLengthMap[styleData.index] = 0
                    } else {
                        if (remainingLength === 0) {
                            assignedLengthMap[styleData.index] =
                                    locationModel.availableSpace(styleData.index,
                                                                 editedPlantingPlantingDate,
                                                                 editedPlantingEndHarvestDate);
                            locationView.addPlantingLength(assignedLengthMap[styleData.index]);
                        } else {
                            assignedLengthMap[styleData.index] =
                                    Math.min(remainingLength,
                                             locationModel.availableSpace(styleData.index,
                                                                          editedPlantingPlantingDate,
                                                                          editedPlantingEndHarvestDate));
                        }
                    }
                    
                    selectionModel.select(styleData.index, ItemSelectionModel.Toggle)
                    assignedLengthMapChanged()
                    locationModel.refreshIndex(styleData.index);
                }
                
                Column {
                    id: column
                    
                    Row {
                        id: row
                        height: Units.rowHeight
                        spacing: Units.smallSpacing
                        leftPadding: 16
                        
                        CheckBox {
                            id: rowCheckBox
                            anchors.verticalCenter: row.verticalCenter
                            visible: locationView.editMode || locationView.alwaysShowCheckbox
                            height: parent.height * 0.8
                            width: height
                            contentItem: Text {}
                            checked: selectionModel.isSelected(styleData.index)
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (mouse.button !== Qt.LeftButton)
                                        return
                                    
                                    selectionModel.select(styleData.index,
                                                          ItemSelectionModel.Toggle)
                                    // Since selectionModel.isSelected() isn't called after
                                    // select(), we refresh the index... Ugly but workin'.
                                    locationModel.refreshIndex(styleData.index)
                                }
                            }
                        }
                        
                        
                        ToolButton {
                            id: locationNameLabel
                            text: hovered ? "\ue889"
                                          : locationSettings.showFullName
                                            ? Location.fullName(locationModel.locationId(styleData.index))
                                            : styleData.value
                            font.family: hovered ? "Material Icons" : "Roboto Regular"
                            font.pixelSize: hovered ? Units.fontSizeTitle : Units.fontSizeBodyAndButton
                            //                                    showToolTip: true
                            //                                        anchors.verticalCenter: parent.verticalCenter
                            //                                    elide: Text.ElideRight
                            //                                    leftPadding: styleData.depth * 20
                            
                            //                                    MouseArea {
                            //                                        id: labelMouseArea
                            //                                        hoverEnabled: true
                            //                                        anchors.fill: parent
                            //                                    }
                            
                            ToolTip.visible: hovered && ToolTip.text
                            ToolTip.text: {
                                var text = ""
                                var plantingIdList = Location.plantings(locationModel.locationId(styleData.index))
                                var plantingId
                                for (var i = 0; i < plantingIdList.length; i++) {
                                    plantingId = plantingIdList[i]
                                    text += Planting.cropName(plantingId)
                                            + ", " + Planting.varietyName(plantingId)
                                            + " " + Planting.plantingDate(plantingId).getFullYear()
                                            + "\n"
                                }
                                return text.slice(0, -1)
                            }
                        }
                        
                        
                        Item {
                            id: namePadder
                            height: Units.rowHeight
                            width: 120 - locationNameLabel.width - row.spacing
                                   - (rowCheckBox.visible
                                      ? rowCheckBox.width + row.spacing
                                      : 0)
                                   - (conflictAlertButton.visible
                                      ? conflictAlertButton.width + row.spacing
                                      : 0)
                                   - (rotationAlertLabel.visible
                                      ? rotationAlertLabel.width + row.spacing
                                      : 0)
                            
                        }
                        
                        ConflictAlertButton {
                            id: conflictAlertButton
                            anchors.verticalCenter: parent.verticalCenter
                            visible: locationModel.hasSpaceConflict(styleData.index, season, year)
                        }
                        
                        ToolButton {
                            id: rotationAlertLabel
                            visible: locationModel.hasRotationConflict(styleData.index, season, year)
                            opacity: visible ? 1 : 0
                            text: "\ue160"
                            font.pixelSize: Units.fontSizeTitle
                            font.family: "Material Icons"
                            Material.foreground: Material.color(Material.Red)
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Behavior on opacity { NumberAnimation { duration: Units.longDuration } }
                            ToolTip.visible: hovered
                            ToolTip.text: {
                                var list = locationModel.rotationConflictingPlantings(styleData.index, season, year)
                                
                                var text = ""
                                var plantingId = -1
                                var locationId = locationModel.locationId(styleData.index)
                                var conflictList = []
                                for (var i = 0; i < list.length; i++) {
                                    plantingId = list[i]
                                    
                                    text += Planting.cropName(plantingId)
                                            + ", " + Planting.varietyName(plantingId)
                                            + " " + Planting.plantingDate(plantingId).getFullYear()
                                    
                                    conflictList = Location.conflictingPlantings(locationId, plantingId)
                                    for (var j = 0; j < conflictList.length; j++) {
                                        var conflictId = conflictList[j]
                                        text += " ⋅ " + Planting.cropName(conflictId)
                                                + ", " + Planting.varietyName(conflictId)
                                                + " " + Planting.plantingDate(conflictId).getFullYear()
                                    }
                                    text += "\n"
                                }
                                return text.slice(0, -1)
                            }
                            
                        }
                        
                        Timeline {
                            height: parent.height
                            visible: locationView.showTimeline
                            year: year
                            season: season
                            showGreenhouseSow: false
                            showNames: true
                            showOnlyActiveColor: true
                            dragActive: true
                            plantingIdList: locationModel.plantings(styleData.index, season, year)
                            locationId: locationModel.locationId(styleData.index)
                            onDragFinished: treeView.draggedPlantingId = -1
                            onPlantingMoved: {
                                locationModel.refreshIndex(styleData.index)
                                locationView.plantingMoved()
                            }
                            onPlantingRemoved: {
                                locationModel.refreshIndex(styleData.index)
                                locationView.plantingRemoved()
                            }
                        }
                    }
                }
                
                ThinDivider {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                }
            }
        }
    }
}
