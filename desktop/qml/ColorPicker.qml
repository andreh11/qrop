import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0
import Qt.labs.platform 1.0 as Lab

import io.croplan.components 1.0
import "date.js" as MDate

Item {
    id: control
    property color color

    signal newColorSelected()

    implicitHeight: gridView.cellHeight * 5

    GridView {
        id: gridView
        anchors.fill: parent
        cellHeight: 46 + Units.smallSpacing
        cellWidth: cellHeight
        clip: true
        highlightFollowsCurrentItem: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollBar
            parent: gridView.parent
            anchors {
                top: gridView.top
                right: gridView.right
                bottom: gridView.bottom

            }
        }

        //                orientation: ListView.Horizontal
        //                spacing: Units.smallSpacing
        model: [
            Material.color(Material.Red, Material.Shade300),
            Material.color(Material.Pink, Material.Shade300),
            Material.color(Material.Purple, Material.Shade300),
            Material.color(Material.DeepPurple, Material.Shade300),
            Material.color(Material.Indigo, Material.Shade300),
            Material.color(Material.Blue, Material.Shade300),
            Material.color(Material.Cyan, Material.Shade300),
            Material.color(Material.Teal, Material.Shade300),
            Material.color(Material.Green, Material.Shade300),
            Material.color(Material.LightGreen, Material.Shade300),
            Material.color(Material.Lime, Material.Shade300),
            Material.color(Material.Yellow, Material.Shade300),
            Material.color(Material.Amber, Material.Shade300),
            Material.color(Material.Orange, Material.Shade300),
            Material.color(Material.DeepOrange, Material.Shade300),
            Material.color(Material.Brown, Material.Shade300),
            Material.color(Material.BlueGrey, Material.Shade300),

            Material.color(Material.Red, Material.Shade700),
            Material.color(Material.Pink, Material.Shade700),
            Material.color(Material.Purple, Material.Shade700),
            Material.color(Material.DeepPurple, Material.Shade700),
            Material.color(Material.Indigo, Material.Shade700),
            Material.color(Material.Blue, Material.Shade700),
            Material.color(Material.Cyan, Material.Shade700),
            Material.color(Material.Teal, Material.Shade700),
            Material.color(Material.Green, Material.Shade700),
            Material.color(Material.LightGreen, Material.Shade700),
            Material.color(Material.Lime, Material.Shade700),
            Material.color(Material.Yellow, Material.Shade700),
            Material.color(Material.Amber, Material.Shade700),
            Material.color(Material.Orange, Material.Shade700),
            Material.color(Material.DeepOrange, Material.Shade700),
            Material.color(Material.Brown, Material.Shade700),
            Material.color(Material.BlueGrey, Material.Shade700)
        ]

        delegate: AbstractButton {
            checkable: true
            width: 46
            height: width
            autoExclusive: true
            onToggled: {
                control.color = modelData
                newColorSelected()
            }

            background: Rectangle {
                id: buttonRectangle
                radius: 46
                color: modelData

                Label {
                    font { family: "Material Icons"; pixelSize: Units.fontSizeHeadline }
                    text: "\ue876"
                    anchors.centerIn: parent
                    color: "white"
                    visible: checked
                }
            }
        }
    }
}