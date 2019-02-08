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

import io.qrop.components 1.0

Page {
    title: qsTr("New Note")

    property NoteModel model: undefined

    function save() {
        var currentDate = new Date()
        notesPage = stackView.get(stackView.index - 1)
        notesPage.model.addNote(textArea.text, "2018-06-27")
    }

    Column {
        spacing: 0
        anchors.fill: parent

        TextArea {
            id: textArea
            height: parent.height/4
            width: parent.width
            padding: 8
            placeholderText: "Tap to enter note"
            font.family: "Roboto Regular"
        }

        Rectangle {
            width: parent.width
            height: 32
            color: Material.color(Material.Teal, Material.Shade400)
            Label {
                text: qsTr("Photos")
                font.family: "Roboto Regular"
            }
        }
    }


}
