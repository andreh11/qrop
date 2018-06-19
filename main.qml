import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtQuick.Controls.Universal 2.1
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "Qrop"

    Settings {
        id: settings
        property bool railMode: false
    }

    Component.onDestruction: {
        settings.railMode = railMode
    }

    readonly property bool largeDisplay: width > 800
    property bool railMode: settings.railMode
    property bool searchMode: false

    // font sizes - defaults from Google Material Design Guide
    property int fontSizeDisplay4: 112
    property int fontSizeDisplay3: 56
    property int fontSizeDisplay2: 45
    property int fontSizeDisplay1: 34
    property int fontSizeHeadline: 24
    property int fontSizeTitle: 20
    property int fontSizeSubheading: 16
    property int fontSizeBodyAndButton: 14 // is Default
    property int fontSizeCaption: 12

    onLargeDisplayChanged: {
        if (!largeDisplay && railMode) {
            railMode = false
        }
    }

    Shortcut {
        sequence: "Ctrl+K"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (!largeDisplay) {
                searchMode = true
            }
            searchField.focus = true
        }
    }

    Component {
        id: searchBar
        ToolBar {
            width: parent.width
            visible: false
            contentHeight: backIcon.implicitHeight
            Material.foreground: "white"

            RowLayout {
               spacing: 20
               anchors.fill: parent
                Label {
                    id: backIcon
                    text: "\ue5c4" // arrow_back
                    color: Material.Grey
                    font.family: "Material Icons"
                    font.pixelSize: 24
                }
                TextField {
                    placeholderText: qsTr("Search")
                    width: 200
                    color: Material.Grey

                }
            }
        }
    }

        header: ToolBar {
            id: toolBar
            visible: true
            leftPadding: 16
            rightPadding: 16
            contentHeight: drawerButton.implicitHeight
//            background: searchMode ? "white" : Material.color(Material.background)
            Material.background: searchMode ? "white" : Material.primary
            Material.foreground: "white"
            z: 1
            RowLayout {
                spacing: 20
                anchors.fill: parent

                ToolButton {
                    id: drawerButton
                    text: stackView.depth > 2 ? "\ue5c4" : "\ue5d2"
                    visible: !largeDisplay && !searchMode
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    onClicked: {
                        if (largeDisplay) {
                            railMode = !railMode
                        } else if (stackView.depth > 2) {
                            stackView.pop()
                        } else if (drawer.opened) {
                            drawer.close()
                        } else {
                            drawer.open()
                        }

                        }
                    }

                ToolButton {
                    id: backButton
                    visible: searchMode
                    text: "\ue5c4" // arrow_back
                    Material.foreground: Material.Grey
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    onClicked: {
                        searchField.clear()
                        searchMode = false
                    }
                }

                Label {
                    id: programLabel
                    text: "Qrop"
                    visible: largeDisplay
                    font.pixelSize: 20
                    font.family: "Roboto Medium"
                    color: "white"
//                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            railMode = !railMode

                        }
                    }
                }

                Label {
                    id: titleLabel
                    text: stackView.currentItem.title
                    visible: !largeDisplay && !searchMode
                    font.pixelSize: 20
                    font.family: "Roboto Medium"
                    color: "white"
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                }

                TextField  {
                    id: searchField
                    leftPadding: 56
                    font.family: "Roboto Regular"
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: 20
                    visible: largeDisplay || searchMode
                    color: "white"
                    placeholderText: qsTr("Search")
                    Layout.fillWidth: true
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height * 0.7
//                        opacity: 0.3
                        color: Material.color(Material.Teal, Material.Shade400)
                        radius: 5
                        Label {
                            leftPadding: 16
                            color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                            text: "\ue8b6" // search
                            font.family: "Material Icons"
                            font.pixelSize: 24
                        }
                    }

                    Shortcut {
                        sequence : "Esc"
                        onActivated: {
                            searchField.clear()
                            searchMode = false
                        }
                    }
                }

                ComboBox {
                    id: yearBox
                    visible: largeDisplay
                    model: [2017, 2018, 2019, 2020]
                    Material.foreground: "white"
                }

                ToolButton {
                    id: searchButton
                    visible: !largeDisplay && !searchMode
                    text: "\ue8b6" // search
                    font.family: "Material Icons"
                    font.pixelSize: 24
                    onClicked: {
                        searchMode = true
                        searchField.focus = true
                    }

                }


//                            ToolButton {
//                                id: menuButton
//                                text: "\ue5d4"
//                                font.family: "Material Icons"
//                                font.pixelSize: 24
//                                onClicked: optionsMenu.open()

//                                Menu {
//                                    id: optionsMenu
//                                    x: parent.width - width
//                                    transformOrigin: Menu.TopRight

//                                    MenuItem {
//                                        text: "Settings"
//                                    }
//                                    MenuItem {
//                                        text: "About"
//                                        onTriggered: aboutDialog.open()
//                                    }
//                                }
//                            }

            }
        }
//    header: StackView {
//        id: toolBarStack
//        height: toolBar.height
//        initialItem: toolBar
//        visible: true
//    }

//    Component {
//        id: toolBar
//    }

    Drawer {
        id: drawer
        width: railMode ? 80 : Math.max(window.width * 0.10, 200)
        height: window.height - toolBar.height
        y: toolBar.height
        modal: !largeDisplay
        interactive: !largeDisplay
        position: largeDisplay ? 1 : 0
        visible: largeDisplay
        Material.background: Material.color(Material.Teal, Material.Shade300)

        Column {
            anchors.fill: parent
            spacing: 6

//            Label {
//                text: "Qrop"
//                color: "white"
//                font.family: "Roboto Medium"
//                font.pixelSize: 20
//                padding: 12
//                horizontalAlignment: Text.AlignLeft
//                verticalAlignment: Text.AlignVCenter
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        railMode = largeDisplay && !railMode
//                    }
//                }
//            }

            DrawerItemDelegate {
                id: button
                text: qsTr("Overview")
                iconText: "\ue871"
                onClicked: {
                    stackView.pop()
                    stackView.push(overviewPage)
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Crops")
                iconText: "\ueb4c" // spa:wa
                onClicked: {
                    stackView.pop()
                    stackView.push(plantingsPage)
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Task Calendar")
                iconText: "\ue876"
                onClicked: {
                    stackView.pop()
                    stackView.push("CalendarPage.qml")
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Crop map")
                iconText: "\ue55b"  // map
                onClicked: {
                    stackView.pop()
                    stackView.push("CropMapPage.qml")
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Harvests")
                iconText: "\ue896" // list
                onClicked: {
                    stackView.pop()
                    stackView.push("HarvestsPage.qml")
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Reports")
                iconText: "\ue801" // poll
                onClicked: {
                    stackView.pop()
                    stackView.push("HarvestsPage.qml")
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }

            DrawerItemDelegate {
                text: qsTr("Settings")
                iconText: "\ue8b8" // settings
                onClicked: {
                    stackView.pop()
                    stackView.push("HarvestsPage.qml")
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }
        }
    }

    OverviewPage {
        id: overviewPage
    }

    PlantingsPage {
        id: plantingsPage
        filterText: searchField.text

    }

    StackView {
        id: stackView
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        initialItem: overviewPage
        topPadding: 20
        leftPadding: 20
        rightPadding: 20
        bottomPadding: 20
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        title: "About"
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                width: aboutDialog.availableWidth
                text: "Logimaraich"
                font.family: "Roboto Medium"
                wrapMode: Label.Wrap
                font.pixelSize: 22
            }

            Label {
                width: aboutDialog.availableWidth
                text: "A modern, cross-platform tool for planning and recordkeeping. Made by farmers, for farmers."
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }
        }
    }
}
