import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Item {
    property alias text: headerLabel.text
    id: header
    height: headerLabel.height
    anchors.verticalCenter: parent.verticalCenter

    Row {
        id: row
        Label {
            id: headerLabel
            color: Material.color(Material.Grey, Material.Shade700)
            font.family: "Roboto Condensed"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: iconLabel
            transformOrigin: Item.Center
            text: ""
//            width: 18
            visible: false
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
                visible: false
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
                text: "\ue5db"
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

    transitions: Transition {
        from: "descending"; to: "ascending"

        RotationAnimation {
            target: iconLabel
            duration: 200
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            switch (header.state) {
            case "":
                header.state = "descending";
                break;
            case "descending":
                header.state = "ascending";
                break;
            case "ascending":
                header.state = "";
                break;
            }
            console.log(header.state)
        }
    }
}
