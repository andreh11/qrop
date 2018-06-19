import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
   title: "Calendar"

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 12


        model: SqlTaskModel {}
        delegate: ItemDelegate {
            id: delegate
            text: model.task + " " + model.planting_ids
        }

//        delegate: Row {
//            id: taskRow
//            spacing: 6

//            Rectangle {
//                width: 48
//                height: parent.height

//                Label {
//                    text: "Pl"
//                    color: "black"
//                    anchors.fill: parent
//                    anchors.margins: 12
//                    font.pixelSize: 37
//                }
//            }
//        }
    }
}
