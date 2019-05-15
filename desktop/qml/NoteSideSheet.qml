/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.10

import io.qrop.components 1.0

Drawer {
    id: noteSideSheet
    edge: Qt.RightEdge
    modal: false
    Material.elevation: 0
    closePolicy: Popup.NoAutoClose
    dragMargin: 0
    
    property int selectedIndex
    property int year

    property alias plantingId: noteModel.plantingId

    signal showPhoto(int noteId)
    signal hidePhoto()

    function refresh() {
        noteView.refresh();
    }

    Platform.FileDialog {
        id: addPhotoDialog
        fileMode: Platform.FileDialog.OpenFiles
        objectName: "openProjectDialog"
        nameFilters: [qsTr("Pictures (*.jpg *.JPG *.jpeg *.JPEG *.png *.PNG *.gif *.GIF)"), qsTr("All files (*)")]
        onAccepted: {
            for (var i = 0; i < files.length; i++)
                photoModel.append({"photoPath": files[i].toString()});
        }
    }

    Component {
        id: sectionHeading
        Rectangle {
            width: parent.width
            height: Units.rowHeight
            //            color: Material.color(Material.Green, Material.Shade200)
            color: Material.color(Material.Grey, Material.Shade100)
            radius: 4

            PlantingLabel {
                year: noteSideSheet.year
                anchors.verticalCenter: parent.verticalCenter
                plantingId: section
                showRank: true
            }

        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Units.smallSpacing
        
        ColumnLayout {
            Layout.leftMargin: Units.mediumSpacing
            Layout.rightMargin: Layout.leftMargin
            
            RowLayout {
                Layout.fillWidth: true
                
                Label {
                    text: qsTr("Notes")
                    font.family: "Roboto Regular"
                    font.bold: true
                    font.pixelSize: Units.fontSizeSubheading
                    Layout.fillWidth: true
                }
                
                ToolButton {
                    text: "\ue14c"
                    font.family: "Material Icons"
                    font.pixelSize: Units.fontSizeHeadline
                    onClicked: noteSideSheet.close()
                }
            }
            
            ListView {
                id: noteView

                function refresh() {
                    var currentY = noteView.contentY
                    noteModel.refresh();
                    noteView.contentY = currentY
                }

                clip: true
                spacing: Units.mediumSpacing
                model: NoteModel {
                    id: noteModel
                }
                
                Layout.fillHeight: true
                Layout.fillWidth: true
                
                ScrollBar.vertical: ScrollBar { }

                section.property: "planting_id"
                section.criteria: ViewSection.FullString
                section.delegate: sectionHeading
                section.labelPositioning: ViewSection.CurrentLabelAtStart |  ViewSection.InlineLabels

                Label {
                    id: emptyStateLabel
                    visible: !noteModel.rowCount
                    text: qsTr("No notes for this planting yet")
                    font.family: "Roboto Regular"
                    font.pixelSize: Units.fontSizeBodyAndButton
                    color: Material.color(Material.Grey)
                    anchors.centerIn: parent
                }

                delegate: ItemDelegate {
                    id: noteDelegate
                    width: parent.width
                    hoverEnabled: true
                    height: noteDelegateRow.height

                    ToolButton {
                        id: showPhotoButton
                        enabled: Note.photoList(model.note_id).length
                        text: "\ue410"
                        font.family: "Material Icons"
                        font.pixelSize: Units.fontSizeHeadline
                        Layout.leftMargin: -padding

                        anchors {
                            right: parent.right
                            top: parent.top
                            leftMargin: -padding
                            topMargin: -padding
                        }

                        onClicked: { showPhoto(model.note_id); }
                    }

                    ToolButton {
                        id: noteDeleteButton
                        visible: noteDelegate.hovered
                        text: "\ue872"
                        font.family: "Material Icons"
                        font.pixelSize: Units.fontSizeHeadline
                        anchors {
                            right: parent.right
                            top: parent.top
                            rightMargin: -padding + showPhotoButton.width
                            topMargin: -padding
                        }
                        Layout.alignment: Qt.AlignTop

                        onClicked: {
                            Note.remove(model.note_id);
                            hidePhoto();
                            noteView.refresh();
                        }
                    }

                    RowLayout {
                        id: noteDelegateRow
                        width: parent.width
                        spacing: Units.smallSpacing

                        Image {
                            visible: false
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: Layout.preferredWidth
                            source: "/icon.png"
                            fillMode: Image.PreserveAspectFit

                            Layout.alignment: Qt.AlignTop
                            Layout.leftMargin: Units.smallSpacing
                            Layout.topMargin: Units.smallSpacing
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumHeight: Units.rowHeight * 1.2
                            Layout.topMargin: Units.smallSpacing

                            Label {
                                Layout.fillWidth: true
                                text: "%1 − %2".arg(MDate.formatDate(model.date, 2019))
                                               .arg(MDate.formatDate(model.date, 2019, "date"))
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: model.content
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
        
        ThinDivider {
            visible: plantingId > 0
            Layout.fillWidth: true
        }
        
        ScrollView {
            implicitHeight: noteSideSheet.height*0.1
            Layout.fillWidth: true
            Layout.leftMargin: Units.mediumSpacing
            Layout.rightMargin: Layout.leftMargin
            visible: plantingId > 0
            
            ScrollBar.vertical: ScrollBar {}
            
            TextArea {
                id: noteTextArea
                width: parent.width
                placeholderText: qsTr("Enter note")
                wrapMode: Text.WordWrap

                Keys.onPressed: {
                    if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                            && event.modifiers & Qt.ControlModifier
                            && addNoteButton.enabled) {
                        addNoteButton.clicked();
                    }
                }
                
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                }
            }
        }

        ListView {
            id: photoView
            clip: true
            visible: plantingId > 0
            spacing: Units.smallSpacing
            model: ListModel {
                id: photoModel
            }
            orientation: ListView.Horizontal
            ScrollBar.horizontal: ScrollBar {}
            
            Layout.fillWidth: true
            Layout.leftMargin: Units.mediumSpacing
            Layout.rightMargin: Layout.leftMargin
            Layout.minimumHeight: 64
            
            delegate:  ItemDelegate {
                width: 64
                height: width
                hoverEnabled: true
                
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth

                Image {
                    id: photoImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: photoPath
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Units.smallSpacing
            Layout.rightMargin: Layout.leftMargin
            visible: plantingId > 0

            ToolButton {
                id: addPhotoButton
                text: "\ue439"
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: addPhotoDialog.open()
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                id: addNoteButton
                text: qsTr("Add")
                flat: true
                enabled: noteTextArea.text && plantingId > 0
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    var noteId = Note.add({"date": new Date().toLocaleString(Qt.locale(), "yyyy-MM-dd"),
                              "content": noteTextArea.text})
                    Note.addPlantingNote(plantingId, noteId);
                    for (var i = 0; i < photoModel.count; i++)
                        Note.addPhoto(photoModel.get(i).photoPath, noteId);

                    noteModel.refresh();
                    noteTextArea.clear();
                    photoModel.clear();
                }
            }
        }
    }
}
