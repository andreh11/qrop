/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
                        model: PlantingModel {
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
