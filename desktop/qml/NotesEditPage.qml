import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

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
