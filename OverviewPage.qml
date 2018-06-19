import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import io.croplan.components 1.0

Page {
    id: page
    title: "Overview"

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 0
        model: SqlTaskModel {}
        delegate:  Row {
            width: parent.width
            spacing: 10
            Rectangle {
                width: 5
                height: 50
                color: model.task === "Planter" ? "red" : "blue"
            }
                Label {
                    width: 100
                    text: model.task
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
