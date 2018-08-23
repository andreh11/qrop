import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Item {
    id: header
    height: headerLabel.height
    anchors.verticalCenter: parent.verticalCenter

//    property var filterLabel
//    property string filterColumn
//    property string columnName
    property alias text: headerLabel.text
    property Item container

    Row {
        id: row
        width: parent.width
        Label {
            id: headerLabel
//            implicitWidth: parent.width - iconLabel.width
            elide: Text.ElideRight
            color: Material.color(Material.Grey, Material.Shade700)
            font.family: "Roboto Condensed"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: iconLabel
            transformOrigin: Item.Center
            text: "\ue5db"
            visible: mouseArea.containsMouse
            color: "black"
            font.family: "Material Icons"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    states: [
        State {
            name: ""
            PropertyChanges {
                target: iconLabel
                visible: mouseArea.containsMouse
            }
            PropertyChanges {
                target: headerLabel
                color: Material.color(Material.Grey, Material.Shade700)
            }
        },

        State {
            name: "descending"
            PropertyChanges {
                target: iconLabel
                visible: true
                rotation: 0
            }
            PropertyChanges {
                target: headerLabel
                color: "black"
            }

        },

        State {
            name: "ascending"
            PropertyChanges {
                target: iconLabel
                visible: true
                text: "\ue5db"
                rotation: 180
            }
            PropertyChanges {
                target: headerLabel
                color: "black"
            }
        }
    ]

    transitions: [
        Transition {
            from: "descending"; to: "ascending"

            RotationAnimation {
                target: iconLabel
                duration: 200
            }
        },

        Transition {
            from: "ascending"; to: "descending"

            RotationAnimation {
                target: iconLabel
                duration: 200
            }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            switch (header.state) {
            case "":
                if (page.tableSortColumn !== index) {
                    page.tableSortColumn = index
                    page.tableSortOrder = Qt.DescendingOrder
                }
                break
            case "descending":
                page.tableSortOrder = Qt.AscendingOrder
                break;
            case "ascending":
                page.tableSortOrder = Qt.DescendingOrder
                break;
            }
        }
    }
}
