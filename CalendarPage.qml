import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.croplan.components 1.0

Page {
    id: page
    title: "Calendar"
    padding: 8

    property int rowHeight: 47
    property bool filterMode: false
    property string filterText: ""
    property int checks: 0

    property var tableHeaderModel: [
        { name: qsTr("Task"),        columnName: "task",    width: 100 },
        { name: qsTr("Description"), columnName: "descr", width: 100 },
        { name: qsTr("Plantings"),   columnName: "planting_ids", width: 150 },
        { name: qsTr("Locations"),   columnName: "place_ids", width: 80 }
    ]

    property int tableSortColumn: 0
    property string tableSortOrder: "descending"

    onTableSortColumnChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName
        tableSortOrder = "descending"
        listView.model.setSortColumn(columnName, tableSortOrder)
    }

    onTableSortOrderChanged: {
        var columnName = tableHeaderModel[tableSortColumn].columnName
        listView.model.setSortColumn(columnName, tableSortOrder)
    }

    TaskDialog {
        id: taskDialog
        width: parent.width / 2
        height: parent.height
        x: (parent.width - width) / 2
    }


    Pane {
        width: parent.width
        height: parent.height
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

                IconButton {
                    text: "\ue5cd" // delete
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
                    text: checks + " task" + (checks > 1 ? "s" : "") + " selected"
                    leftPadding: 16
                    color: Material.color(Material.Blue)
                    Layout.fillWidth: true
                    visible: checks > 0
                    font.family: "Roboto Regular"
                    font.pixelSize: 16
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }

                ToolButton {
                    font.pixelSize: fontSizeBodyAndButton
                    leftPadding: 24
                    visible: checks === 0
                    text: qsTr("Add task")
                    onClicked: taskDialog.open()
                }

                Label {
                    Layout.fillWidth: true
                }

                CardSpinBox {
                    visible: checks === 0
                    id: weekSpinBox
                    from: 1
                    to: 52
                    value: 34
                }

                CardSpinBox {
                    visible: checks === 0
                    id: yearSpinBox
                    from: 2000
                    to: 2100
                    value: 2018
                }

                IconButton {
                    text: "\ue3c9" // edit
                    visible: checks > 0
                }

                IconButton {
                    text: "\ue14d" // content_copy
                    visible: checks > 0
                }

                IconButton {
                    text: "\ue872" // delete
                    visible: checks > 0
                }

                IconButton {
                    text: "\ue152" // filter_list
                    visible: checks === 0
                    onClicked: {
                        filterMode = true
                        filterField.focus = true
                    }
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

            model: SqlTaskModel {}

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: headerRectangle
                height: headerRow.height
                width: parent.width
                color: "white"
                z: 3
                Column {
                    width: parent.width

                    Row {
                        id: headerRow
                        height: rowHeight
                        spacing: 18
                        leftPadding: 16

                        CheckBox {
                            id: headerCheckbox
                            width: 24
                            anchors.verticalCenter: headerRow.verticalCenter
                        }

                        Repeater {
                            model: page.tableHeaderModel

                            TableHeaderLabel {
                                text: modelData.name
                                width: modelData.width
                                state: page.tableSortColumn === index ? page.tableSortOrder : ""
                            }
                        }
                    }
                }
            }

            delegate: Rectangle {
                height: row.height
                width: parent.width
                color: {
                    if (checkBox.checked) {
                        return Material.color(Material.primary, Material.Shade100)
                    } else if (mouseArea.containsMouse) {
                        return Material.color(Material.Grey, Material.Shade100)
                    } else {
                        return "white"
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Column {
                    width: parent.width

                    ThinDivider {
                    }

                    Row {
                        id: row
                        height: rowHeight
                        spacing: 18
                        leftPadding: 16

                        CheckBox {
                            id: checkBox
                            anchors.verticalCenter: row.verticalCenter
                            width: 24
                            onCheckStateChanged: {
                                if (checked) {
                                    checks = checks + 1
                                } else {
                                    checks = checks - 1
                                }
                            }
                        }

                        TableLabel {
                            text: model.task
                            elide: Text.ElideRight
                            width: 100
                        }

                        TableLabel {
                            text: model.descr
                            elide: Text.ElideRight
                            width: 100
                        }

                        TableLabel {
                            text: model.planting_ids
                            elide: Text.ElideRight
                            width: 150
                        }

                        TableLabel {
                            text: model.place_ids
                            elide: Text.ElideRight
                            width: 80
                        }
                    }
                }
            }
        }
    }
}



//            anchors.top: buttonRectangle.bottom
