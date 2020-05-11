/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

ApplicationWindow {
    id: window

    property var navigationModel: [
        { source: plantingsPage, name: qsTr("Plantings"), iconText: "\ue0b8" },
        { source: calendarPage,  name: qsTr("Tasks"),     iconText: "\ue614" },
        { source: locationsPage, name: qsTr("Crop Map"),  iconText: "\ue55b" },
        { source: harvestsPage,  name: qsTr("Harvests"),  iconText: "\ue896" },
        { source: seedListPage,  name: qsTr("Seed list"), iconText: "\ue8ef" },
        { source: chartsPage,    name: qsTr("Charts"),    iconText: "\ue801" },
        { source: notesPage,     name: qsTr("Notes"),     iconText: "\ue616" }
    ]
    property int navigationIndex: 0

    readonly property bool largeDisplay: width > 800
    readonly property bool smallDisplay: width < 500
    property bool railMode: width > 1200
    property bool searchMode: false
    property bool showSaveButton: false
    property string searchString: searchField.text
    property alias stackView: stackView
    property int oldWindowVisibility: Window.Windowed
    property string currentDatabaseFile: "" // "" is main database
    property string secondDatabaseFile: ""

    // TODO: put this in a separate file
    readonly property var monthsOrder : [
        [6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5],
        [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        [3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2]
    ]

    function toggleFullScreen() {
        if (window.visibility === Window.FullScreen) {
            window.visibility = oldWindowVisibility
        } else {
            oldWindowVisibility = window.visibility
            window.visibility = Window.FullScreen
        }
    }

    title: "Qrop"
    visible: true
    width: 1024
    height: 768
    flags: Qt.Window

    Material.primary: Material.color(Material.Teal, Material.Shade500)
    Material.accent: Material.color(Material.Blue, Material.Shade600)

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

    function switchToDatabase(db) {
        if (db === "main") {
            if (currentDatabaseFile !== "") {
                Database.connectToDatabase();
                currentDatabaseFile = "";
            }
        }  else if (db === "second") {
            if (currentDatabaseFile !== "second") {
                Database.connectToDatabase(secondDatabaseFile);
                currentDatabaseFile = secondDatabaseFile;
            }
        }
        if (locationsPage.item) {
            locationsPage.item.reload();
        }
        stackView.currentItem.item.refresh();
    }

    Platform.FileDialog {
        id: openDatabaseDialog

        defaultSuffix: "sqlite"
        fileMode: Platform.FileDialog.OpenFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("SQLITE (*.sqlite)")]
        onAccepted: {
            secondDatabaseFile = file;
            switchToDatabase("second");
        }
    }

    Platform.FileDialog {
        id: newDatabaseDialog

        defaultSuffix: "sqlite"
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("SQLITE (*.sqlite)")]
        onAccepted: {
            secondDatabaseFile = file;
            switchToDatabase("second");
        }
    }

    Platform.FileDialog {
        id: saveMainDatabaseDialog

        defaultSuffix: "sqlite"
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("SQLITE (*.sqlite)")]
        onAccepted: {
            Database.saveAs(file);
        }
    }

    Platform.FileDialog {
        id: replaceMainDatabaseDialog

        defaultSuffix: "sqlite"
        fileMode: Platform.FileDialog.OpenFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("SQLITE (*.sqlite)")]
        onAccepted: {
            Database.replaceMainDatabase(file);
            switchToDatabase("main");
        }
    }

    Platform.FileDialog {
        id: saveSecondDatabaseDialog

        defaultSuffix: "sqlite"
        fileMode: Platform.FileDialog.SaveFile
        folder: Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation)
        nameFilters: [qsTr("SQLITE (*.sqlite)")]
        onAccepted: {
            Database.copy(secondDatabaseFile, file);
        }
    }


    Loader {
        id: plantingsPage
        source: "PlantingsPage.qml"
    }

    Loader {
        id: calendarPage
//        asynchronous: true
//        visible: status == Loader.Ready
    }

    Loader {
        id: locationsPage
//        asynchronous: true
//        visible: status == Loader.Ready
    }

    Loader {
        id: harvestsPage
    }

    Loader {
        id: chartsPage
    }

    Loader {
        id: notesPage
    }

    Loader {
        id: seedListPage
    }

    Loader {
        id: settingsPage
    }

    Settings {
        id: mainSettings
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
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
        sequence: "Ctrl+5"
        context: Qt.ApplicationShortcut
        onActivated: navigationIndex = 4
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
                    anchors.verticalCenter: parent.verticalCenter
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
        Material.elevation: 0
        contentHeight: drawerButton.implicitHeight
        Material.background: searchMode ? "white" : Material.primary
        Material.foreground: "white"
        z: 1

        RowLayout {
            spacing: Units.mediumSpacing
            anchors.fill: parent

            ToolButton {
                id: drawerButton
                text: stackView.depth > 1 ? "\ue5c4" : "\ue5d2"
                visible: !searchMode
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
                Material.foreground: Material.accent
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: {
                    searchField.clear()
                    searchMode = false
                }
            }

            Label {
                id: titleLabel
                text: stackView.currentItem.item.title
                visible: !searchMode
                font.pixelSize: Units.fontSizeTitle
                font.family: "Roboto Medium"
//                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            SearchField {
                id: searchField
                placeholderText: qsTr("Search Plantings")
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhPreferLowercase

                filterModel: [
                    qsTr("All"),
                    qsTr("Greenhouse"),
                    qsTr("Field"),
                ]
            }

//            TextField  {
//                id: searchField
//                font.family: "Roboto Regular"
//                verticalAlignment: Qt.AlignVCenter
//                font.pixelSize: Units.fontSizeBodyAndButton
//                visible: searchMode
//                color: "black"
//                placeholderText: qsTr("Search")
//                Layout.fillWidth: true
//                background: Rectangle {
//                    anchors.verticalCenter: parent.verticalCenter
//                    height: parent.height
//                }

//                Shortcut {
//                    sequence : "Esc"
//                    onActivated: {
//                        searchField.clear()
//                        searchMode = false
//                    }
//                }
//            }

            ToolButton {
                id: saveButton
                visible: showSaveButton
                text: "\ue876"
                font.family: "Material Icons"
                font.capitalization: Font.Capitalize
                font.pixelSize: Units.fontSizeHeadline
                Layout.margins: -padding
                onClicked: {
                    stackView.currentItem.save()
                    stackView.pop()
                    showSaveButton = false
                }
            }

//            ToolButton {
//                id: searchButton
//                visible: !searchMode && !showSaveButton
//                text: "\ue8b6" // search
//                font.family: "Material Icons"
//                font.pixelSize: Units.fontSizeHeadline
//                Layout.margins: -padding
//                onClicked: {
//                    searchMode = true
//                    searchField.focus = true
//                }
//            }

            ToolButton {
                id: overflowMenu
                visible: !searchMode
                text: "\ue5d4" // menu
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                Layout.margins: -padding
                onClicked: {
                }
            }
        }
    }

    Drawer {
        id: drawer
        //        width: largeDisplay && railMode ? programLabel.width : Math.max(window.width * 0.10, 200)
//                width: childrenRect.width
        height: window.height
//        width: 72
        //        height: window.height - toolBar.height
//        y: menuBar.height
        modal: !largeDisplay
        interactive: !largeDisplay
        position: largeDisplay ? 1 : 0
        visible: largeDisplay
//        Material.background: Material.primary
        Material.background: "white"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: navigationModel

                DrawerItemDelegate {
                    Layout.fillWidth: true
                    width: drawer.width
                    text: modelData.name
                    iconText: modelData.iconText
                    onClicked: {
                        navigationIndex = index
                        if (!largeDisplay)
                            drawer.close()
                    }
                }
            }

            Item { Layout.fillHeight: true }

            DrawerItemDelegate {
                id: mainDatabase
                Layout.fillWidth: true
                width: drawer.width
                text: qsTr("Main database")
                iconText: "\ue400"
                isActive: currentDatabaseFile == ""

                onClicked: switchToDatabase("main");
                onPressAndHold: {
                    mainDatabaseMenu.open();
                }

                Menu {
                    id: mainDatabaseMenu
                    title: qsTr("Main database menu")
                    x: parent.width
                    margins: 0

                    MenuItem {
                        text: qsTr("Export")
                        onClicked: saveMainDatabaseDialog.open();
                    }

                    MenuItem {
                        text: qsTr("Replace")
                        onClicked: replaceMainDatabaseDialog.open();
                    }
                }
            }

            DrawerItemDelegate {
                id: secondDatabaseButton
                Layout.fillWidth: true
                width: drawer.width
                text: qsTr("Second database")
                showToolTip: false
                iconText: "\ue401"
                iconColor: secondDatabaseFile === "" ?  Material.color(Material.Grey,
                                                                       Material.Shade400)
                                                     : "white"
                isActive: currentDatabaseFile != ""

                onClicked: {
                    if (secondDatabaseFile != "")
                        switchToDatabase("second");
                    else
                        databaseMenu.open();
                }

                onPressAndHold: {
                    databaseMenu.open();
                }

                ToolTip {
                    text: secondDatabaseFile == "" ? qsTr("No other database opened")
                                                   : secondDatabaseFile
                    visible: parent.hovered
                    x: parent.width + Units.smallSpacing
                    y: height/4
                }

                Menu {
                    id: databaseMenu
                    title: qsTr("Database menu")
                    x: parent.width
                    margins: 0

                    MenuItem {
                        text: qsTr("New")
                        onClicked: newDatabaseDialog.open();
                    }

                    MenuItem {
                        text: qsTr("Open")
                        onClicked: openDatabaseDialog.open();
                    }

                    MenuItem {
                        text: qsTr("Export")
                        onClicked: saveSecondDatabaseDialog.open();
                        enabled: secondDatabaseFile !== ""
                    }
                }
            }

            DrawerItemDelegate {
                id: settingsDrawerButton
                Layout.fillWidth: true
                width: drawer.width
                text: qsTr("Settings")
                iconText: "\ue8b8"
                isActive: navigationModel.length == navigationIndex

                onClicked: {
                    navigationIndex = navigationModel.length
                    if (!largeDisplay)
                        drawer.close()
                }
            }

            DrawerItemDelegate {
                id: aboutDrawerDelegate
                Layout.fillWidth: true
                width: drawer.width
                text: qsTr("About")
                iconText: "\ue887"
                isActive: false

                onClicked: {
                    aboutDialog.open();
                }
            }
        }
    }

    Component {
        id: busyPage
        Page {
            BusyIndicator {
                anchors.centerIn: parent
                running: true
            }
        }
    }

    StackView {
        id: stackView
        focus: true
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        anchors.rightMargin: 0
        topPadding: 20
        leftPadding: 20
        rightPadding: 20
        bottomPadding: 20

        initialItem: plantingsPage
        replaceEnter: null
        replaceExit: null

        Rectangle {
            id: buttonRectangle
            visible: stackView.currentItem.status === Loader.Loading
            //            color: checks > 0 ? Material.color(Material.Cyan, Material.Shade100) : "white"
            width: parent.width
            height: Units.toolBarHeight
            Material.elevation: 2

            ThinDivider {
                id: topDivider
                anchors.top: buttonRectangle.bottom
                width: parent.width
            }

            ProgressBar {
                anchors { top: topDivider.top; left: parent.left; right: parent.right }
                indeterminate: true
            }
        }

        function activatePage(index) {
            switch (index) {
            case 0:
                if (plantingsPage.status === Loader.Null)
                    plantingsPage.source = "PlantingsPage.qml";
                stackView.replace(plantingsPage)
                plantingsPage.item.refresh();
                break;
            case 1:
                if (calendarPage.status === Loader.Null)
                    calendarPage.source = "CalendarPage.qml";
                stackView.replace(calendarPage);
                calendarPage.item.refresh();
                break
            case 2:
                if (locationsPage.status === Loader.Null) {
                    stackView.replace(busyPage);
                    locationsPage.source = "LocationsPage.qml";
                }
                stackView.replace(locationsPage)
                locationsPage.item.refresh();
                break
            case 3:
                if (harvestsPage.status === Loader.Null)
                    harvestsPage.source = "HarvestsPage.qml";
                stackView.replace(harvestsPage)
                harvestsPage.item.refresh();
                break
            case 4:
                if (seedListPage.status === Loader.Null)
                    seedListPage.source = "SeedsPage.qml";
                stackView.replace(seedListPage)
                seedListPage.item.refresh();
                break
            case 5:
                if (chartsPage.status === Loader.Null)
                    chartsPage.source = "ChartsPage.qml";
                stackView.replace(chartsPage)
                chartsPage.item.refresh();
                break
            case 6:
                if (notesPage.status === Loader.Null)
                    notesPage.source = "NotesPage.qml";
                stackView.replace(notesPage)
                notesPage.item.refresh();
                break
            case 7:
                if (settingsPage.status === Loader.Null)
                    settingsPage.setSource("SettingsPage.qml",
                                           { "paneWidth": Math.min(600, stackView.width * 0.8) })
                stackView.replace(settingsPage)
//                settingsPage.item.refresh();
                break
            }
        }
    }

    AboutDialog {
        id: aboutDialog
        x: (window.width - width) / 2
        y: (window.height - height) / 2
        width: 500
    }
}
