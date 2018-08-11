import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
    title: "Harvests"

    Pane {
        width: 120
        height: 120
        anchors.centerIn: parent

        Material.elevation: 6

        Label {
            text: qsTr("I'm a card!")
            anchors.centerIn: parent
        }
    }
}
