import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

Item {
    property alias text: cardLabel.text
    property Item paneContent
    Column {
        spacing: 8

        Label {
            id: cardLabel
            color: Material.color(Material.accent)
            font.family: "Roboto Regular"
            font.capitalization: Font.AllUppercase
        }

        Pane {
            id: cardPane
            width: parent.width
            height: parent.height
            Material.elevation: 1
//            children: paneContent
        }
    }
}
