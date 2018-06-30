import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
    title: "Plantings"
    padding: 8
    property bool showTimegraph: timegraphButton.checked
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0

    Pane {
        anchors.fill: parent
        padding: 0
        Material.elevation: 1

        Rectangle {
            id: buttonRectangle
            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            visible: true
            width: parent.width
            height: 48
            RowLayout {
                id: filterRow
                anchors.fill: parent
                spacing: 0
                visible: filterMode

                TextField  {
                    id: filterField
                    leftPadding: 16 + largeDisplay ? 50 : 0
                    font.family: "Roboto Regular"
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: 20
                    color: "black"
                    placeholderText: qsTr("Search")
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter
                    Shortcut {
                        sequence: "Escape"
                        onActivated: {
                            filterMode = false
                            filterField.text = ""
                        }

                    }
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height * 0.7
                        Label {
                            leftPadding: 16
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\ue8b6" // search
                            font.family: "Material Icons"
                            font.pixelSize: 24
                        }
                    }
                }

                ToolButton {
                    text: "\ue5cd" // delete
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    onClicked: {
                        filterMode = false
                        filterField.text = ""
                    }
                }
            }

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                spacing: 0
                visible: !filterMode
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: checks + " item" + (checks > 1 ? "s" : "") + " selected"
                    leftPadding: 16
                    color: Material.color(Material.Blue)
                    Layout.fillWidth: true
                    visible: checks > 0
                    font.family: "Roboto Regular"
                    font.pixelSize: 16
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }
                Label {
                    text: qsTr("Plantings")
                    visible: checks === 0
                    leftPadding: 16
                    font.family: "Roboto Regular"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }

                ToolButton {
                    text: "\ue3c9" // edit
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    visible: checks > 0
                }
                ToolButton {
                    text: "\ue14d" // content_copy
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    visible: checks > 0
                }
                ToolButton {
                    text: "\ue872" // delete
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    visible: checks > 0
                }
                ToolButton {
                    id: timegraphButton
                    hoverEnabled: true
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    text: "\ue0b8"
                    visible: largeDisplay && checks == 0
                    checkable: true
                    checked: true

                    ToolTip.visible: hovered
                    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                    ToolTip.text: checked ? qsTr("Hide timegraph") : qsTr("Show timegraph")
                }
                ToolButton {
                    text: "\ue152" // filter_list
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    visible: checks === 0
                    onClicked: {
                        filterMode = true
                        filterField.focus = true
                    }

                }
                ToolButton {
                    text: "\ue145" // add
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    width: 24
                    visible: checks === 0
                }
            }
        }

        ListView {
            id: listView
            visible: true
            clip: true
            width: parent.width
            height: parent.height - buttonRectangle.height
            spacing: 0
            anchors.top: buttonRectangle.bottom
            ScrollBar.vertical: ScrollBar {
                visible: largeDisplay
                parent: listView.parent
                anchors.top: listView.top
                anchors.left: listView.right
                anchors.bottom: listView.bottom
            }
            Shortcut {
                sequence: "Ctrl+K"
                onActivated: {
                    filterMode = true
                    filterField.focus = true
                }
            }

            //                                section.property: "crop"
            //                                section.criteria: ViewSection.FullString
            //        section.delegate: sectionHeading

            model: SqlPlantingModel {
                crop: filterField.text
            }
            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: headerRectangle
                height: headerRow.height
                width: parent.width
                color: headerCheckbox.checked ? Material.color(Material.primary, Material.Shade100) : "white"
                z: 3
                Column {
                    width: parent.width

                    Row {
                        id: headerRow
                        height: 47
                        spacing: 18
                        leftPadding: 16

                        CheckBox {
                            id: headerCheckbox
                            width: 24
                        }

                        TableHeaderLabel {
                            text: qsTr("Crop")
                            width: 120
                        }
                        TableHeaderLabel {
                            text: qsTr("Variety")
                            width: 120
                        }
                        Item {
                            height: parent.height
                            width: headerTimelineRow.width
                            visible: showTimegraph
                            //                        width: 200
                            Row {
                                id: headerTimelineRow
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                spacing: 0
                                Repeater {
                                    model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
                                    Item {
                                        width: 61
                                        height: parent.height
                                        Rectangle {
                                            id: lineRectangle
                                            height: parent.height
                                            width: 1
                                            color: Material.color(Material.Grey, Material.Shade400)
                                        }
                                        Label {
                                            text: modelData
                                            anchors.left: lineRectangle.right
                                            font.family: "Roboto Condensed"
                                            color: Material.color(Material.Grey, Material.Shade700)
                                            width: 60 - 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            horizontalAlignment: Text.AlignHCenter

                                        }
                                    }
                                }
                                Rectangle {
                                    height: parent.height
                                    width: 1
                                    color: Material.color(Material.Grey, Material.Shade400)
                                }
                            }
                        }
                        TableHeaderLabel {
                            text: qsTr("Seeding date")
                            width: 120
                        }
                    }
                }
            }

            delegate: Rectangle {
                height: row.height
                width: parent.width
                color: checkBox.checked ? Material.color(Material.primary, Material.Shade100) : (mouseArea.containsMouse ? Material.color(Material.Grey, Material.Shade100) : "white")
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                Column {
                    width: parent.width
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Material.color(Material.Grey, Material.Shade400)
                    }

                    Row {
                        id: row
                        height: 47
                        spacing: 18
                        leftPadding: 16

                        CheckBox {
                            id: checkBox
                            width: 24
                            onCheckStateChanged: {
                                if (checked) {
                                    checks = checks + 1
                                } else {
                                    checks = checks - 1
                                }
                            }
                        }

                        Label {
                            text: model.crop
                            font.family: "Roboto Condensed"
                            font.pixelSize: 14
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label {
                            text: model.variety
                            font.family: "Roboto Condensed"
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Timeline {
                            visible: showTimegraph
                            seedingDate: model.seeding_date
                            transplantingDate: model.transplanting_date
                            beginHarvestDate: model.beg_harvest_date
                            endHarvestDate: model.end_harvest_date
                        }
                        Label {
                            text: model.seeding_date
                            font.family: "Roboto Condensed"
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

        }

    }

    RoundButton {
        id: addButton
        font.family: "Material Icons"
        font.pixelSize: 20
        text: "\ue145"
        width: 56
        height: width
        // Don't want to use anchors for the y position, because it will anchor
        // to the footer, leaving a large vertical gap.
        y: parent.height - height
        anchors.right: parent.right
        //        anchors.margins: 12
        visible: !largeDisplay
        highlighted: true

        onClicked: {
        }
    }

}
