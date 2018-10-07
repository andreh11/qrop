import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Item {
    id: control
    height: headerLabel.height
    anchors.verticalCenter: parent.verticalCenter

//    property var filterLabel
//    property string filterColumn
//    property string columnName
    property alias text: headerLabel.text
    property Item container

    property int horizontalAlignment: Text.AlignLeft

    RowLayout {
        id: row
        width: parent.width
        spacing: 0

        Label {
            Layout.fillWidth: control.horizontalAlignment === Text.AlignRight
        }

        Label {
            id: leftIconLabel
            transformOrigin: Item.Center
            text: "\ue5db"
            visible: control.horizontalAlignment === Text.AlignRight && mouseArea.containsMouse
            horizontalAlignment: control.horizontalAlignment
            color: "black"
            font.family: "Material Icons"
            font.pixelSize: 16
        }

        Label {
            id: headerLabel
            width: parent.width - leftIconLabel.width
            elide: Text.ElideRight
            color: Material.color(Material.Grey, Material.Shade700)
            font.family: "Roboto Condensed"
            font.pixelSize: 14
            horizontalAlignment: control.horizontalAlignment
            maximumLineCount: 5
//            Layout.fillWidth: true
        }

        Label {
            id: rightIconLabel
            transformOrigin: Item.Center
            text: "\ue5db"
            visible: mouseArea.containsMouse && !leftIconLabel.visible
            horizontalAlignment: control.horizontalAlignment
            color: "black"
            font.family: "Material Icons"
            font.pixelSize: 16
        }

        Label {
            Layout.fillWidth: control.horizontalAlignment === Text.AlignLeft
        }
    }

    states: [
        State {
            name: ""
            PropertyChanges {
                target: leftIconLabel
                visible: mouseArea.containsMouse
            }
            PropertyChanges {
                target: RightIconLabel
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
            switch (control.state) {
            case "":
                if (page.tableSortColumn !== index) {
                    page.tableSortColumn = index
                    page.tableSortOrder = "descending"
                }
                break
            case "descending":
                page.tableSortOrder = "ascending"
                break;
            case "ascending":
                page.tableSortOrder = "descending"
                break;
            }
        }
    }
}
