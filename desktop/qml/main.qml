/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
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

    readonly property bool largeDisplay: width > 800
    readonly property bool smallDisplay: width < 500
    property bool railMode: width > 1200
    property bool searchMode: false
    property bool showSaveButton: false
    property int oldWindowVisibility: Window.Windowed

    property string currentDatabaseFile: "" // "" is main database
    property string secondDatabaseFile: ""

    property int navigationIndex: 0
    property var navigationModel: [
        { loader: plantingsPage, name: qsTr("Plantings"), iconText: "\ue0b8", component: "PlantingsPage.qml" },
        { loader: calendarPage,  name: qsTr("Tasks"),     iconText: "\ue614", component: "CalendarPage.qml" },
        { loader: locationsPage, name: qsTr("Crop Map"),  iconText: "\ue55b", component: "LocationsPage.qml" },
        { loader: harvestsPage,  name: qsTr("Harvests"),  iconText: "\ue896", component: "HarvestsPage.qml" },
        { loader: seedListPage,  name: qsTr("Seed list"), iconText: "\ue8ef", component: "SeedsPage.qml" },
        { loader: chartsPage,    name: qsTr("Charts"),    iconText: "\ue801", component: "ChartsPage.qml" },
        { loader: notesPage,     name: qsTr("Notes"),     iconText: "\ue616", component: "NotesPage.qml" },
        { loader: settingsPage,  name: qsTr("Settings"),  iconText: "\ue616", component: "SettingsPage.qml",
          bindings: { "paneWidth": Math.min(600, stackLayout.width * 0.8) }}
    ]

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

    function switchToNextPane() {
        if (navigationIndex === navigationModel.length) {
            navigationIndex = 0;
        } else {
            navigationIndex++;
        }
    }

    function switchToPreviousPane() {
        if (navigationIndex === 0) {
            navigationIndex = navigationModel.length;
        } else {
            navigationModel--;
        }
    }

    function switchToDatabase(db) {
        if (db === "main") {
            if (currentDatabaseFile !== "") {
                Database.connectToDatabase();
                currentDatabaseFile = "";
            }
        } else if (db === "second") {
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

    title: "Qrop"
    visible: true
    width: 1024
    height: 768
    flags: Qt.Window

    Material.primary: Material.color(Material.Teal, Material.Shade500)
    Material.accent: Material.color(Material.Blue, Material.Shade600)

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

    Settings {
        id: mainSettings
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
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

    ApplicationShortcut { sequence: StandardKey.Quit; onActivated: Qt.quit() }
    ApplicationShortcut { sequence: "Ctrl+1"; onActivated: navigationIndex = 0 }
    ApplicationShortcut { sequence: "Ctrl+2"; onActivated: navigationIndex = 1 }
    ApplicationShortcut { sequence: "Ctrl+3"; onActivated: navigationIndex = 2 }
    ApplicationShortcut { sequence: "Ctrl+4"; onActivated: navigationIndex = 3 }
    ApplicationShortcut { sequence: "Ctrl+5"; onActivated: navigationIndex = 4 }
    ApplicationShortcut { sequence: "Ctrl+6"; onActivated: navigationIndex = 5 }
    ApplicationShortcut { sequence: "Ctrl+7"; onActivated: navigationIndex = 6 }
    ApplicationShortcut { sequence: "Ctrl+0"; onActivated: navigationIndex = navigationModel.length - 1 }
    ApplicationShortcut { sequence: StandardKey.NextChild; onActivated: switchToNextPane() }
    ApplicationShortcut { sequence: StandardKey.PreviousChild; onActivated: switchToPreviousPane() }
    ApplicationShortcut { sequence: "F11"; onActivated: toggleFullScreen() }

    Drawer {
        id: drawer
        height: window.height
        modal: !largeDisplay
        interactive: !largeDisplay
        position: largeDisplay ? 1 : 0
        visible: largeDisplay
        Material.background: Material.primary

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Repeater {
                // We remove the last item because Settings icon is a the bottom of the Drawer.
                model: navigationModel.slice(0, -1)

                DrawerItemDelegate {
                    Layout.fillWidth: true
                    width: drawer.width
                    text: modelData.name
                    iconText: modelData.iconText
                    isActive: index === navigationIndex
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
                onPressAndHold: mainDatabaseMenu.open();

                Menu {
                    id: mainDatabaseMenu
                    title: qsTr("Main database menu")
                    x: parent.width
                    margins: 0

                    MenuItem { text: qsTr("Export"); onClicked: saveMainDatabaseDialog.open(); }
                    MenuItem { text: qsTr("Replace"); onClicked: replaceMainDatabaseDialog.open(); }
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

                onPressAndHold: databaseMenu.open();

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

                    MenuItem { text: qsTr("New"); onClicked: newDatabaseDialog.open(); }
                    MenuItem { text: qsTr("Open"); onClicked: openDatabaseDialog.open(); }
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
                    navigationIndex = navigationModel.length - 1
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

                onClicked: aboutDialog.open();
            }
        }
    }

    Rectangle {
        id: busyRectangle
        visible: stackLayout.isLoading
        width: parent.width
        height: Units.toolBarHeight
        Material.elevation: 2

        ThinDivider {
            id: topDivider
            anchors.top: parent.bottom
            width: parent.width
        }

        ProgressBar {
            anchors { top: topDivider.bottom; left: parent.left; right: parent.right }
            indeterminate: true
        }
    }

    StackLayout {
        id: stackLayout

        property bool isLoading: children[currentIndex].status === Loader.Loading

        focus: true
        anchors.fill: parent
        anchors.leftMargin: largeDisplay ? drawer.width : undefined
        anchors.rightMargin: 0
        currentIndex: navigationIndex

        onCurrentIndexChanged: {
            let index = currentIndex;
            if (index >= navigationModel.length) {
                return;
            }

            if (navigationModel[index].loader.status === Loader.Null) {
                if (navigationModel[index].bindings) {
                    navigationModel[index].loader.setSource(navigationModel[index].component,
                                                      navigationModel[index].bindings);
                } else {
                    navigationModel[index].loader.setSource(navigationModel[index].component);
                }
            } else {
                navigationModel[index].loader.item.refresh();
            }
        }

        Loader { id: plantingsPage; source: "PlantingsPage.qml"; asynchronous: true }
        Loader { id: calendarPage; asynchronous: true }
        Loader { id: locationsPage; asynchronous: true  }
        Loader { id: harvestsPage; asynchronous: true  }
        Loader { id: seedListPage; asynchronous: true  }
        Loader { id: chartsPage; asynchronous: true  }
        Loader { id: notesPage; asynchronous: true  }
        Loader { id: settingsPage; asynchronous: true  }
    }

    AboutDialog {
        id: aboutDialog
        x: (window.width - width) / 2
        y: (window.height - height) / 2
        width: 500
    }
}
