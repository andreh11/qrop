/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.10

import io.qrop.components 1.0
import "date.js" as MDate

ApplicationWindow {
    id: window

    property var navigationModel: [
        //        { source: "OverviewPage.qml",  name: qsTr("Dashboard"), iconText: "\ue871" },
        { source: plantingsPage, name: qsTr("Plantings"), iconText: "\ue0b8" },
        { source: calendarPage,  name: qsTr("Tasks"),     iconText: "\ue614" },
        { source: locationsPage,   name: qsTr("Crop Map"),  iconText: "\ue8f1" },
        { source: harvestsPage,  name: qsTr("Harvests"),  iconText: "\ue896" }
//        { source: notesPage,     name: qsTr("Notes"),     iconText: "\ue616" }
        //        { source: "ChartsPage.qml",    name: qsTr("Charts"),    iconText: "\ue801" },
    ]
    property int navigationIndex: 0

    readonly property bool largeDisplay: width > 800
    readonly property bool smallDisplay: width < 500
    property bool railMode: false
    property bool searchMode: false
    property bool showSaveButton: false
    property string searchString: searchField.text
    property alias stackView: stackView
    property int oldWindowVisibility: Window.Windowed

    // TODO: put this in a separate file
    readonly property var monthsOrder : [
        [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        [3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2],
        [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5],
    ]

    function toggleFullScreen() {
        if (window.visibility === Window.FullScreen) {
            window.visibility = oldWindowVisibility
        }
        else {
            oldWindowVisibility = window.visibility
            window.visibility = Window.FullScreen
        }
    }

    title: "Qrop"
    visible: true
    width: 1024
    height: 768

    Material.primary: Material.Teal
    Material.accent: Material.Indigo

    onNavigationIndexChanged: stackView.activatePage(navigationIndex)

    Dialog {
        id: imageDialog
        property alias path: dialogPhotoImage.source
        x: (window.width - width) / 2
        y: (window.height - height) / 2

        Image {
            id: dialogPhotoImage
            width: parent.width*0.8
            height: parent.height*0.8
            fillMode: Image.PreserveAspectFit
        }
    }

    PlantingsPage {
        id: plantingsPage
    }

    CalendarPage {
        id: calendarPage
    }

    LocationsPage {
        id: locationsPage
    }

    HarvestsPage {
        id: harvestsPage
    }

    NotesPage {
        id: notesPage
    }

    SettingsPage {
        id: settingsPage
    }

    Shortcut {
        sequence: StandardKey.Quit
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Ctrl+1"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = 0
    }

    Shortcut {
        sequence: "Ctrl+2"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = 1
    }

    Shortcut {
        sequence: "Ctrl+3"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = 2
    }

    Shortcut {
        sequence: "Ctrl+4"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = 3
    }

    Shortcut {
        sequence: "Ctrl+0"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = navigationModel.length
    }

    Shortcut {
        sequence: StandardKey.NextChild
        context: Qt.ApplicationShortcut
        onActivated: {
            if (navigationIndex === navigationModel.length)
                navigationIndex = 0;
            else
                navigationIndex++;
        }
    }

    Shortcut {
        sequence: StandardKey.PreviousChild
        context: Qt.ApplicationShortcut
        onActivated: {
            if (navigationIndex === 0)
                navigationIndex = navigationModel.length;
            else
                navigationModel--;
        }
    }

    Shortcut {
        objectName: "fullScreenToggleShortcut"
        context: Qt.ApplicationShortcut
        sequence: "F11"
        onActivated: toggleFullScreen()
    }

    Settings {
        id: settings
        property alias railMode: window.railMode
        property alias windowX: window.x
        property alias windowY: window.y
        property alias windowHeight: window.height
        property alias windowWidth: window.width
        property alias windowVisibility: window.visibility
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

        Platform.Menu {
            id: helpMenu
            objectName: "helpMenu"
            title: qsTr("Help")

            Platform.MenuItem {
                objectName: "aboutMenuButton"
                text: qsTr("About...")
                onTriggered: aboutDialog.open()
            }
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
                spacing: Units.mediumDuration
                anchors.fill: parent
                BackIcon {
                    id: backIcon
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
        height: 56
        contentHeight: drawerButton.implicitHeight
        //            background: searchMode ? "white" : Material.color(Material.background)
        Material.background: searchMode ? "white" : Material.primary
        Material.foreground: "white"
        z: 1
        RowLayout {
            spacing: Units.mediumSpacing
            anchors.fill: parent

            ToolButton {
                id: drawerButton
                text: stackView.depth > 1 ? "\ue5c4" : "\ue5d2"
                visible: !largeDisplay && !searchMode
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: {
                    if (largeDisplay) {
                        railMode = !railMode
                    } else if (stackView.depth > 1) {
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
                font.pixelSize: Units.fontSizeHeadline
                onClicked: {
                    searchField.clear()
                    searchMode = false
                }
            }

            Label {
                id: titleLabel
                text: stackView.currentItem.title
                visible: !largeDisplay && !searchMode
                font.pixelSize: Units.fontSizeTitle
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
                font.pixelSize: Units.fontSizeTitle
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
                        font.pixelSize: Units.fontSizeHeadline
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
                font.pixelSize: Units.fontSizeHeadline
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
                font.pixelSize: Units.fontSizeHeadline
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
        //        width: largeDisplay && railMode ? programLabel.width : Math.max(window.width * 0.10, 200)
        //        width: childrenRect.width
        height: window.height
        //        height: window.height - toolBar.height
        //        y: toolBar.height
        modal: !largeDisplay
        interactive: !largeDisplay
        position: largeDisplay ? 1 : 0
        visible: largeDisplay
        //        Material.background: Material.color(Material.Teal, Material.Shade300)
        Material.background: Material.primary

        //        background: Rectangle {
        //            anchors.fill: parent
        //            color: "green"
        //        }

        ColumnLayout {
            anchors.fill: parent

            Label {
                id: programLabel
                visible: false
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
                    Layout.fillWidth: true
                    width: drawer.width
                    text: modelData.name
                    iconText: modelData.iconText
                    onClicked: {
                        navigationIndex = index
                        if (!largeDisplay) {
                            drawer.close()
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            DrawerItemDelegate {
                Layout.fillWidth: true
                width: drawer.width
                text: qsTr("Settings")
                iconText: "\ue8b8"
                isActive: navigationModel.length == navigationIndex

                onClicked: {
                    navigationIndex = navigationModel.length
                    if (!largeDisplay) {
                        drawer.close()
                    }
                }
            }
        }
    }

    NoteSideSheet {
        id: noteSideSheet
        height: window.height
        width: Math.min(300, window.width*0.3)
        plantingId: plantingsPage.checks ? plantingsPage.selectedIdList()[0] : -1
        onClosed: photoPane.visible = false
        onShowPhoto: {
            photoPane.photoIdList = Note.photoList(noteId)
            photoPane.visible = true
        }
        onHidePhoto: photoPane.visible = false
    }

    RoundButton {
        id: noteButton
        z:3
        visible: navigationIndex === 0
        Material.background: "white"
        width: 72
        height: width
        anchors.right: parent.right
        anchors.rightMargin: visible ? -width/2 : 0
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            if(!noteSideSheet.opened) {
                console.log("open!")
                noteSideSheet.open();
            }
        }

        contentItem: Text {
            text: "\ue24d"
            font.family: "Material Icons"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        ToolTip.visible: hovered
        ToolTip.text: qsTr("Show the note pane")
        ToolTip.delay: Units.shortDuration
    }

    PhotoPane {
        id: photoPane
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        anchors.rightMargin: noteSideSheet.opened ? noteSideSheet.width : 0
        visible: false
        z: 3
    }

    StackView {
        id: stackView
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        anchors.rightMargin: noteSideSheet.opened ? noteSideSheet.width : 0
        topPadding: 20
        leftPadding: 20
        rightPadding: 20
        bottomPadding: 20

        initialItem: plantingsPage

        replaceEnter: null
        replaceExit: null

        function activatePage(index) {
            switch (index) {
            case 0:
                stackView.replace(plantingsPage)
                plantingsPage.refresh();
                break;
            case 1:
                stackView.replace(calendarPage)
                calendarPage.refresh();
                break
            case 2:
                stackView.replace(locationsPage)
                locationsPage.refresh();
                break
            case 3:
                stackView.replace(harvestsPage)
                harvestsPage.refresh();
                break
//            case 4:
//                stackView.replace(notesPage)
//                notesPage.refresh();
//                break
            case 4:
                stackView.replace(settingsPage)
                break
            }
        }
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        title: qsTr("About Qrop")
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Image {
                source: "/icon.png"
                width: 100
                height: width
            }

            Label {
                width: aboutDialog.availableWidth
                text: "Qrop"
                font.family: "Roboto Medium"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeSubheading
            }

            Label {
                width: aboutDialog.availableWidth
                text: qsTr("A modern, cross-platform tool for planning and recordkeeping. Made by farmers, for farmers.")
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeBodyAndButton
            }
        }
    }
}
