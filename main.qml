import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtQuick.Controls.Universal 2.1
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

ApplicationWindow {
    id: window
    title: "Qrop"
    visible: true
    width: 1024
    height: 768

    Material.primary: Material.Teal
    Material.accent: Material.Cyan

    property var navigationModel: [
        { source: "OverviewPage.qml",  name: qsTr("Dashboard"), iconText: "\ue871" },
        { source: "PlantingsPage.qml", name: qsTr("Plantings"), iconText: "\ueb4c" },
        { source: "CalendarPage.qml",  name: qsTr("Tasks"),     iconText: "\ue876" },
        { source: "CropMapPage.qml",   name: qsTr("Crop Map"),  iconText: "\ue55b" },
        { source: "HarvestsPage.qml",  name: qsTr("Harvests"),  iconText: "\ue896" },
        { source: "NotesPage.qml",     name: qsTr("Notes"),     iconText: "\ue616" },
        { source: "ChartsPage.qml",    name: qsTr("Charts"),    iconText: "\ue801" },
        { source: "Settings.qml",      name: qsTr("Settings"),  iconText: "\ue8b8" }
    ]
    property int navigationIndex: 0
    onNavigationIndexChanged: stackView.activatePage(navigationIndex)

    readonly property bool largeDisplay: width > 800
    property bool railMode: true
    property bool searchMode: false
    property bool showSaveButton: false
    property string searchString: searchField.text
    property alias stackView: stackView

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

    Settings {
        id: settings
        property alias railMode: window.railMode
        property alias windowX: window.x
        property alias windowY: window.y
        property alias windowHeight: window.height
        property alias windowWidth: window.width
        property alias windowVisibility: window.visibility
    }

    function week(date) {
        var target = new Date(date.valueOf())
        var dayNr = (date.getDay() + 6) % 7
        target.setDate(target.getDate() - dayNr + 3)
        var firstThursday = target.valueOf()
        target.setMonth(0, 1)
        if (target.getDay() !== 4) {
            target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7)
        }
        var retVal = 1 + Math.ceil((firstThursday - target) / 604800000)

        return (retVal < 10 ? '0' + retVal : retVal)
    }

    Platform.MenuBar {
        Platform.Menu {
            id: fileMenu
            objectName: "fileMenu"
            title: qsTr("File")

            Platform.MenuItem {
                objectName: "quitMenuButton"
                text: qsTr("Quit")
            }
        }
    }

//    Shortcut {
//        sequence: "Ctrl+K"
//        context: Qt.ApplicationShortcut
//        onActivated: {
//            if (!largeDisplay) {
//                searchMode = true
//            }
//            searchField.focus = true
//        }
//    }

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
        visible: !largeDisplay
        leftPadding: 8 + (largeDisplay ? drawer.width : 0)
        rightPadding: 8
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

//            Label {
//                id: programLabel
//                text: "Qrop"
//                visible: largeDisplay
//                font.pixelSize: 20
//                font.family: "Roboto Medium"
//                color: "white"
//                //                    Layout.fillWidth: true
//                horizontalAlignment: Qt.AlignLeft
//                verticalAlignment: Qt.AlignVCenter
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        railMode = !railMode

//                    }
//                }
//            }


            Label {
                id: titleLabel
                text: stackView.currentItem.title
                visible: !largeDisplay && !searchMode
                font.pixelSize: 20
                font.family: "Roboto Medium"
//                color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }


            TextField  {
                id: searchField
                leftPadding: 16 + largeDisplay ? 50 : 0
                font.family: "Roboto Regular"
                verticalAlignment: Qt.AlignVCenter
                font.pixelSize: 20
                visible: largeDisplay || searchMode
                color: "black"
                placeholderText: qsTr("Search")
                Layout.fillWidth: true
                background: Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height * 0.7
//                    width: parent.width
                    //                        opacity: 0.3
//                    color: largeDisplay ? Material.color(Material.Teal, Material.Shade400) : "white"
                    radius: 5
                    Label {
                        leftPadding: 16
                        visible: largeDisplay
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

            ToolButton {
                id: saveButton
                visible: showSaveButton
                text: "\ue876"
                font.family: "Material Icons"
                font.capitalization: Font.Capitalize
                font.pixelSize: 24
                onClicked: {
                    stackView.currentItem.save()
                    stackView.pop()
                    showSaveButton = false
                }
            }

            ToolButton {
                id: searchButton
                visible: !largeDisplay && !searchMode && !showSaveButton
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

    Drawer {
        id: drawer
        width: largeDisplay && railMode ? programLabel.width : Math.max(window.width * 0.10, 200)
        height: window.height
//        height: window.height - toolBar.height
//        y: toolBar.height
        modal: !largeDisplay
        interactive: !largeDisplay
        position: largeDisplay ? 1 : 0
        visible: largeDisplay
//        Material.background: Material.color(Material.Teal, Material.Shade300)
        Material.background: Material.primary

        Column {
            anchors.fill: parent

            Label {
                id: programLabel
                height: toolBar.height
                text: "Qrop"
                color: "white"
                font.family: "Roboto Bold"
                font.pixelSize: 20
                padding: 12
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        railMode = largeDisplay && !railMode
                    }
                }
            }

            Repeater {
                model: navigationModel

                DrawerItemDelegate {
                    text: modelData.name
                    iconText: modelData.iconText
                }

            }
        }
    }

    Repeater {
        id: pages
        model: navigationModel

        Loader {
            property string title
            source: modelData.source
            onLoaded: title = item.title
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        topPadding: 20
        leftPadding: 20
        rightPadding: 20
        bottomPadding: 20


        function activatePage(index) {
            if (index < pages.count)
                stackView.replace(pages.itemAt(index))
        }

        Component.onCompleted: stackView.push(pages.itemAt(0))
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
