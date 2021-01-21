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

    readonly property bool largeDisplay: width > 100
    readonly property bool smallDisplay: width < 500
    property bool railMode: width > 1200
    property bool searchMode: false
    property bool showSaveButton: false
    property int oldWindowVisibility: Window.Windowed

    property string firstDatabaseFile: settings.firstDatabaseFile
    property string secondDatabaseFile: settings.secondDatabaseFile
    property int currentDatabase: settings.currentDatabase
    property string lastFolder: settings.lastFolder

    property int navigationIndex: 0
    property var navigationModel: [
        { loader: plantingsPage, name: qsTr("Plantings"), iconText: "\ue0b8", component: "PlantingsPage.qml" },
        { loader: calendarPage,  name: qsTr("Tasks"),     iconText: "\ue614", component: "CalendarPage.qml" },
        { loader: locationsPage, name: qsTr("Crop Map"),  iconText: "\ue55b", component: "LocationsPage.qml" },
        { loader: harvestsPage,  name: qsTr("Harvests"),  iconText: "\ue896", component: "HarvestsPage.qml" },
        { loader: seedListPage,  name: qsTr("Seed list"), iconText: "\ue8ef", component: "SeedsPage.qml" },
        { loader: chartsPage,    name: qsTr("Charts"),    iconText: "\ue801", component: "ChartsPage.qml" },
//        { loader: notesPage,     name: qsTr("Notes"),     iconText: "\ue616", component: "NotesPage.qml" },
        { loader: settingsPage,  name: qsTr("Settings"),  iconText: "\ue616", component: "SettingsPage.qml",
          bindings: { "paneWidth": Math.min(600, stackLayout.width * 0.8) }}
    ]

    enum DB_ACTION {
        OPEN = 0,
        NEW  = 1,
        SAVE = 2
    }

    property bool modifyMainDatabase: true
    property int dbAction: Qrop.DB_ACTION.OPEN

    property int popupTimeout : 8000

    Component.onCompleted: {
        if (firstDatabaseFile === "")
            firstDatabaseFile = cppRemote.defaultDatabaseUrl();
        if (currentDatabase === 0)
            currentDatabase = 1;
        if (lastFolder === "")
            lastFolder = '%1%2'.arg(BuildInfo.isMobileDevice() ? "" : "file://").arg(FileSystem.rootPath);
    }

    Connections {
        target: cppQrop

        onInfo: info(msg);
        onError: error(err);
    }

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

    function switchToDatabase() {
        let dbName = window.currentDatabase === 1 ? firstDatabaseFile : secondDatabaseFile;
        if (!cppQrop.loadDatabase(dbName))
            error(qsTr("Error opening database: %1").arg(dbName));
        if (locationsPage.item)
            locationsPage.item.reload();
        stackLayout.currentItem.refresh();
    }
    
    function openDatabaseActionDialog(action, mainDB) {
        dbAction = action;
        modifyMainDatabase = mainDB;
        if (BuildInfo.isMobileDevice()){
            if (action === Qrop.DB_ACTION.OPEN) {
                let availableDBs = FileSystem.getAvailableDataBasesNames();
                if (availableDBs.length === 0)
                    error(qsTr('There are no database available...'),
                          '%1: <b>%2</b>'.arg(
                              qsTr("They should all be copied in the following folder")).arg(
                              FileSystem.rootPath));
                else {
//                    for (var i=0; i < availableDBs.length; ++i)
//                        print("[MB_TRACE] Available DB: "+availableDBs[i]);
                    databaseMobileDialog.nameField.visible = false;
                    databaseMobileDialog.combo.visible = true;
                    databaseMobileDialog.combo.model = availableDBs;
                    databaseMobileDialog.title = modifyMainDatabase ?
                                qsTr('Open Main DataBase') : qsTr('Open Secondary DataBase');
                    databaseMobileDialog.text = '%1<br/>%2 %3'.arg(
                                qsTr("Please select a database to open")).arg(
                                qsTr("They must all be in the folder:")).arg(
                                FileSystem.rootPath);
                    databaseMobileDialog.open();
                }
            } else {
                databaseMobileDialog.nameField.visible = true;
                databaseMobileDialog.combo.visible = false;
                if (action === Qrop.DB_ACTION.NEW) {
                    databaseMobileDialog.title = modifyMainDatabase ?
                                qsTr('New Main DataBase') : qsTr('New Secondary DataBase');
                } else {
                    databaseMobileDialog.title = modifyMainDatabase ?
                                qsTr('Export Main DataBase') : qsTr('Export Secondary DataBase');
                }
                databaseMobileDialog.text = qsTr("Database name:");
                databaseMobileDialog.open();
            }
        } else {
            databaseDialog.fileMode = action === Qrop.DB_ACTION.OPEN ?
                        Platform.FileDialog.OpenFile : Platform.FileDialog.SaveFile;
            databaseDialog.open();
        }
    }

    function doDatabaseAction(file){
//        print("DB Action: "+dbAction);
        if (dbAction == Qrop.DB_ACTION.SAVE) { // NOT === just a double == !!!
            // MB_TODO: remove all call to Database to use cppQrop instead
            Database.copy(modifyMainDatabase ? firstDatabaseFile : secondDatabaseFile, file);
        } else {
            if (modifyMainDatabase) {
                firstDatabaseFile = file;
                currentDatabase = 1;
            } else {
                secondDatabaseFile = file;
                currentDatabase = 2;
            }
            switchToDatabase();
        }
    } // doDatabaseAction
    
    function info(text) {
        infoSnackbar.text = text;
        infoSnackbar.open();
    }

    function error(text) {
        info("<font color='darkred'>%1</font>".arg(text));
    }

    title: "Qrop"
    visible: true
    width: 1024
    height: 768
    flags: Qt.Window

    Material.primary: Material.color(Material.Teal, Material.Shade500)
    Material.accent: Material.color(Material.Blue, Material.Shade600)

    Settings {
        id: mainSettings
        property bool useStandardBedLength
        property int standardBedLength
        property bool showPlantingSuccessionNumber
    }

    Settings {
        id: settings
        property alias windowX: window.x
        property alias windowY: window.y
        property alias windowHeight: window.height
        property alias windowWidth: window.width
        property alias windowVisibility: window.visibility

        property alias firstDatabaseFile: window.firstDatabaseFile
        property alias secondDatabaseFile: window.secondDatabaseFile
        property alias currentDatabase: window.currentDatabase
        property alias lastFolder: window.lastFolder
    }

    ApplicationShortcut { sequence: StandardKey.Quit; onActivated: Qt.quit() }
    ApplicationShortcut { sequence: "Ctrl+1"; onActivated: navigationIndex = 0 }
    ApplicationShortcut { sequence: "Ctrl+2"; onActivated: navigationIndex = 1 }
    ApplicationShortcut { sequence: "Ctrl+3"; onActivated: navigationIndex = 2 }
    ApplicationShortcut { sequence: "Ctrl+4"; onActivated: navigationIndex = 3 }
    ApplicationShortcut { sequence: "Ctrl+5"; onActivated: navigationIndex = 4 }
    ApplicationShortcut { sequence: "Ctrl+6"; onActivated: navigationIndex = 5 }
//    ApplicationShortcut { sequence: "Ctrl+7"; onActivated: navigationIndex = 6 }
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
                text: Helpers.urlBaseName(firstDatabaseFile)
                iconText: "\ue400"
                isActive: currentDatabase === 1
                showToolTip: false

                onClicked: {
                    if (currentDatabase !== 1) {
                        currentDatabase = 1;
                        switchToDatabase();
                    }
                }

                onPressAndHold: mainDatabaseMenu.open();

                Menu {
                    id: mainDatabaseMenu
                    title: qsTr("Main database menu")
                    x: parent.width
                    margins: 0

                    MenuItem {
                        text: qsTr("New...");
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.NEW, true);
                    }
                    MenuItem {
                        text: qsTr("Open...");
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.OPEN, true);
                    }
                    MenuItem {
                        text: qsTr("Export...");
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.SAVE, true);
                    }
                }

                ToolTip {
                    text: firstDatabaseFile
                    visible: parent.hovered
                    x: parent.width + Units.smallSpacing
                    y: height/4
                }
            }

            DrawerItemDelegate {
                id: secondDatabaseButton
                Layout.fillWidth: true
                width: drawer.width
                showToolTip: false
                iconText: "\ue401"
                text: secondDatabaseFile === "" ? "" : Helpers.urlBaseName(secondDatabaseFile)
                iconColor: secondDatabaseFile === ""
                           ?  Material.color(Material.Grey, Material.Shade400)
                           : "white"

                isActive: currentDatabase === 2

                onClicked: {
                    if (currentDatabase !== 2) {
                        if (secondDatabaseFile !== "") {
                            currentDatabase = 2
                            switchToDatabase();
                        } else {
                            databaseMenu.open();
                        }
                    }
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

                    MenuItem {
                        text: qsTr("New...");
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.NEW, false);
                    }
                    MenuItem {
                        text: qsTr("Open...");
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.OPEN, false);
                    }
                    MenuItem {
                        text: qsTr("Export...")
                        enabled: secondDatabaseFile !== ""
                        onTriggered: openDatabaseActionDialog(Qrop.DB_ACTION.SAVE, false);
                    }
                    MenuItem {
                        text: qsTr("Close");
                        enabled: secondDatabaseFile !== ""
                        onTriggered: {
                            if (currentDatabase === 2) {
                                currentDatabase = 1;
                                switchToDatabase();
                            }
                            secondDatabaseFile = ""
                        }
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
        property var currentItem: children[currentIndex].item

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
//        Loader { id: notesPage; asynchronous: true  }
        Loader { id: settingsPage; asynchronous: false  }
    }

    AboutDialog {
        id: aboutDialog
        x: (window.width - width) / 2
        y: (window.height - height) / 2
        width: 500
    }

    Snackbar {
        id: infoSnackbar
        z: 2
        x: drawer.width + Units.mediumSpacing
        y: parent.height - height - Units.mediumSpacing
        visible: false
    }

    Platform.FileDialog {
        id: databaseDialog

        defaultSuffix: "sqlite"
        folder: Qt.resolvedUrl(window.lastFolder)
        nameFilters: [("SQLite (*.db *.sqlite)")]
        onAccepted: {
            doDatabaseAction(file)
            lastFolder = folder.toString();
        }
    } // databaseDialog

    MobileFileDialog {
        id: databaseMobileDialog

        x: (window.width - width) / 2
        y: (window.height - height) / 2

        onAccepted: {
            //MB_TODO: check if the file already exist? shall we overwrite or discard?
            let dbName = dbAction == Qrop.DB_ACTION.OPEN ? combo.currentText : nameField.text;
            doDatabaseAction('file://%1/%2.sqlite'.arg(FileSystem.rootPath).arg(dbName));
        }
    }
}
