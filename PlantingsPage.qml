import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
    title: "Plantings"
    padding: 16
    property bool showTimegraph: true
    property string filterText: ""

    //    Component {
    //        id: sectionHeading
    //        Rectangle {
    //            width: listView.width
    //            height: childrenRect.height
    //            color: Material.accent

    //            Text {
    //                text: section
    //                color: "white"
    //                font.bold: true
    //                font.pixelSize: 20
    //
    //        }

    //    }
    Row {
        id: buttonRow
        width: parent.width
        height: 48
        ToolButton {
            text: qsTr("Add")
        }
        ToolButton {
            text: qsTr("Edit")
        }
        ToolButton {
            text: qsTr("Duplicate")
        }
        ToolButton {
            text: qsTr("Remove")
        }
    }

    ListView {
        id: listView
        width: parent.width
        height: parent.height - buttonRow.height
        spacing: 0
        anchors.top: buttonRow.bottom
        ScrollBar.vertical: ScrollBar {
            parent: listView.parent
            anchors.top: listView.top
            anchors.left: listView.right
            anchors.bottom: listView.bottom
        }
        //                section.property: "crop"
        //                section.criteria: ViewSection.FullString
        //        section.delegate: sectionHeading

        model: SqlPlantingModel {
            crop: filterText
        }

//        populate: Transition {
//            NumberAnimation { properties: "y"; duration: 200 }
//        }
        headerPositioning: ListView.OverlayHeader
        header: Rectangle {
            id: headerRectangle
            height: headerRow.height
            width: parent.width
            color: headerCheckbox.checked ? Material.color(Material.primary, Material.Shade100) : (headerRectangle.hovered ? "red" : "white")
            z: 3
            Column {
                width: parent.width
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Material.color(Material.Grey, Material.Shade400)
                }

                Row {
                    id: headerRow
                    height: 47
                    spacing: 18
                    leftPadding: 16

                    CheckBox {
                        id: headerCheckbox
                        width: 24
                    }

                    Label {
                        text: qsTr("Crop")
                        color: Material.color(Material.Grey, Material.Shade700)
                        font.family: "Roboto Condensed"
                        font.pixelSize: 14
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: qsTr("Variety")
                        font.family: "Roboto Condensed"
                        color: Material.color(Material.Grey, Material.Shade700)
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item {
                        height: parent.height
                        width: headerTimelineRow.width
                        visible: showTimegraph
                        //                        width: 200
                        Row {
                            id: headerTimelineRow
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            spacing: 0
                            Repeater {
                                model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
                                Rectangle {
                                    height: parent.height
                                    width: 1
                                    color: Material.color(Material.Grey, Material.Shade400)
                                }
                                Label {
                                    text: modelData
                                    font.family: "Roboto Condensed"
                                    color: Material.color(Material.Grey, Material.Shade700)
                                    width: 60 - headerRow.spacing - 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    horizontalAlignment: Text.AlignHCenter

                                }
                            }
                        }
//                        Timeline {
//                            seedingDate: new Date(2018, 2, 3)
//                            transplantingDate: new Date(2018, 3, 4)
//                            beginHarvestDate: new Date(2018, 4, 17)
//                            endHarvestDate: new Date(2018, 4, 27)
//                        }
                    }
                }
            }
        }

//        delegate: Rectangle {
//            height: row.height
//            width: parent.width
////            color: checkBox.checked ? Material.color(Material.primary, Material.Shade100) : "white"
//            Column {
//                Rectangle {
//                    width: parent.width
//                    height: 1
//                    color: Material.color(Material.Grey, Material.Shade400)
//                }
//                Row {
//                    id: row
//                    height: 47 * 2
//                    spacing: 18
//                    leftPadding: 16
//                    Label {
//                        text: model.crop
//                        font.family: "Roboto Condensed"
//                        font.pixelSize: 14
//                        anchors.verticalCenter: parent.verticalCenter
//                    }
//                    Label {
//                        text: model.variety
//                        font.family: "Roboto Condensed"
//                        anchors.verticalCenter: parent.verticalCenter
//                    }

////                    CheckBox {
////                        id: checkBox
////                        width: 24
////                    }
//                }

//            }

        delegate: Rectangle {
            height: row.height
            width: parent.width
            color: checkBox.checked ? Material.color(Material.primary, Material.Shade100) : "white"
            Column {
                width: parent.width
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Material.color(Material.Grey, Material.Shade400)
                }

                Row {
                    id: row
                    height: 47
                    spacing: 18
                    leftPadding: 16

                    CheckBox {
                        id: checkBox
                        width: 24
                    }

                    Label {
                        text: model.crop
                        font.family: "Roboto Condensed"
                        font.pixelSize: 14
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: model.variety
                        font.family: "Roboto Condensed"
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Timeline {
                            seedingDate: model.seeding_date
                            transplantingDate: model.transplanting_date
                            beginHarvestDate: model.beg_harvest_date
                            endHarvestDate: model.end_harvest_date
                    }
                    Label {
                        text: model.seeding_date
                        font.family: "Roboto Condensed"
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    RoundButton {
        id: addButton
        font.family: "Material Icons"
        font.pixelSize: 20
        text: "\ue145"
        width: 56
        height: width
        // Don't want to use anchors for the y position, because it will anchor
        // to the footer, leaving a large vertical gap.
        y: parent.height - height
        anchors.right: parent.right
        //        anchors.margins: 12
        visible: !largeDisplay
        highlighted: true

        onClicked: {
        }
    }
}
