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
    title: "Notes"
    id: page
    property alias model: listView.model

    RowLayout {
        anchors.fill: parent
        spacing: 16
        ListView {
            id: listView
            clip: true
            width: parent.width / 2
            height: parent.height
            anchors.leftMargin: largeDisplay ? 46 : 0
            anchors.topMargin: anchors.leftMargin
            anchors.rightMargin: anchors.leftMargin
            spacing: 0
            //        anchors.top: buttonRow.bottom
            ScrollBar.vertical: ScrollBar {
                visible: largeDisplay
                parent: listView.parent
            }
            //                section.property: "crop"
            //                section.criteria: ViewSection.FullString
            //        section.delegate: sectionHeading

            model: NoteModel {
                id: sqlModel
                //            crop: filterText
            }
            delegate: Rectangle {
                height: row.height
                width: parent.width
                //            color: checkBox.checked ? Material.color(Material.primary, Material.Shade100) : "white"
                Column {
                    width: parent.width
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: mouseArea.hovered ? Material.color(Material.Grey, Material.Shade600): Material.color(Material.Grey, Material.Shade400)
                        MouseArea {
                            id: mouseArea
                            hoverEnabled: true
                            anchors.fill: parent
                        }

                        Column {
                            id: row
                            height: 47 * 2
                            spacing: 8
                            //                    leftPadding: 16
                            padding: 16
                            Label {
                                text: model.text
                                font.family: "Roboto Regular"
                                font.pixelSize: 14
                                //                        anchors.verticalCenter: parent.verticalCenter
                            }
                            Label {
                                text: model.date_modified
                                font.pixelSize: 12
                                color: Material.color(Material.Grey)
                                font.family: "Roboto Regular"
                                //                        anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("clicked!")
                }
            }

        }

        NotesEditPage {
            id: notesEditPage
            visible: largeDisplay
            model: sqlModel
            width: largeDisplay ? parent.width / 2 : parent.width
            height: parent.height
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
            stackView.push(notesEditPage)
            showSaveButton = true
        }
    }
}
