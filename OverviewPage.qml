import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

Page {
    id: page
    title: "Overview"

    Flickable {
        anchors.fill: parent
        Grid {
            anchors.fill: parent
            spacing: 16
            anchors.margins: 8
            columns: largeDisplay ? 2 : 1
//            Card {
//                height: parent.height/2
//                width: largeDisplay ? parent.width / 2 : parent.width
//                text: "Today's tasks"

//                //                Label {
//                //                    text: "Today's tasks"
//                //                    color: Material.color(Material.accent)
//                //                    font.family: "Roboto Regular"
//                //                    font.capitalization: Font.AllUppercase
//                //                }

//                //                content: Pane {
//                //                    id: taskCard
//                ////                    width: largeDisplay ? parent.width / 2 : parent.width
//                //                    width: parent.width
//                //                    height: parent.height
//                //                    Material.elevation: 2
//                //                    padding: 0

//                paneContent: ListView {
//                    id: listView
//                    anchors.fill: parent
//                    spacing: 0
//                    clip: true
//                    model: SqlTaskModel {}
//                    delegate:  Column {
//                        spacing: 0
//                        width: parent.width
//                        height: 50
//                        Row {
//                            width: parent.width
//                            height: parent.height
//                            spacing: 10
//                            Rectangle {
//                                width: 5
//                                height: parent.height
//                                color: model.task === "Planter" ? "red" : "blue"
//                            }
//                            Label {
//                                topPadding: 8
//                                font.family: "Roboto Regular"
//                                width: 100
//                                text: model.task
//                            }
//                        }

//                        Rectangle {
//                            width: parent.width
//                            height: 1
//                            color: Material.color(Material.Grey, Material.Shade300)
//                        }
//                    }

//                }

//            }

            Column {
                height: parent.height/2
                width: largeDisplay ? parent.width / 2 : parent.width
                spacing: 8

                Label {
                    text: "Recent crops"
                    color: Material.color(Material.accent)
                    font.family: "Roboto Regular"
                    font.capitalization: Font.AllUppercase
                }
                Pane {
                    width: parent.width
                    height: parent.height
                    //        anchors.fill: parent
                    Material.elevation: 2
                    ListView {
                        id: cropView
                        anchors.fill: parent
                        spacing: 0
                        clip: true
                        model: SqlPlantingModel {
                            crop: searchString
                        }
                        delegate:  Row {
                            width: parent.width
                            height: 50
                            spacing: 10
                            Rectangle {
                                width: 5
                                height: parent.height
                                color: model.crop === "Tomate" ? "red" : "Green"
                            }
                            Column {
                                height: parent.height
                                Label {
                                    text: model.crop
                                    font.family: "Roboto Regular"
                                }
                                Label {
                                    text: model.variety
                                    font.family: "Roboto Regular"
                                    color: Material.color(Material.Grey)
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}
//    RowLayout {
//        spacing: 16
//        anchors.fill: parent
//        ListView {
//            Material.elevation: 6
//            anchors.fill: parent
//            id: listView
//            spacing: 12
//            model: SqlPlantingModel {}
//            delegate: ItemDelegate {
//                id: delegate
//                text: model.crop + " " + model.variety
//            }
//        }
//    }
