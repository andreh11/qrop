/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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

import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.0

MyTextField {
    id: control

    property alias model: listView.model
    property int selectedId: -1
    property string addItemText: ""
    property bool showAddItem
    property bool manuallyModified: false
    property bool autoOpenPopupOnFocus: true

    property var textRole: function (model) { return ""; }
    property var idRole: function (model) { return -1; }

    signal addItemClicked()

    function reset() {
        manuallyModified = false;
        selectedId = -1;
        text = "";
    }

    function setSelectedId(id) {
        selectedId = id;
        listView.currentIndex = model.idRow(id);
    }

    focus: true
    autoJumpToNextItem: false
    Keys.priority: Keys.AfterItem
    Keys.forwardTo: [listView.currentItem, listView]

    onTextEdited: {
        if (activeFocus) {
            model.filterString = text.trim();
            listView.currentIndex = 0;
            selectedId = -1
            if (!popup.opened) {
                popup.open();
            }
        }
    }

    Keys.onEnterPressed: {
        if (!model.rowCount) {
            popup.close();
            addItemClicked()
        }
    }

    Keys.onReturnPressed:  {
        if (!model.rowCount) {
            popup.close();
            addItemClicked()
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            if (autoOpenPopupOnFocus) {
                popup.open();
            }
            model.filterString = "";
        } else {
            if (selectedId < 0 &&
                    (focusReason === Qt.TabFocusReason
                     || focusReason === Qt.BacktabFocusReason
                     || focusReason === Qt.MouseFocusReason )) {
               clear();
            }
            popup.close();
        }
    }

    RoundButton {
        y: (Units.fieldHeight - height)/2
        flat: true
        anchors.right: control.right
        anchors.rightMargin: -padding/2
        text: "\ue5c5"
        font.family: "Material Icons"
        font.pixelSize: Units.fontSizeHeadline
        focusPolicy: Qt.NoFocus

        onClicked: {
            if (!popup.opened) {
                model.filterString = "";
                control.forceActiveFocus();
                popup.open();
            }
        }
    }

    Popup {
        id: popup
        y: parent.height - 8
        padding: 0
        width: control.width
        height: ApplicationWindow.window
                ? Math.min(listView.implicitHeight + addItemRectangle.height,
                           ApplicationWindow.window.height/2 - topMargin - bottomMargin)
                : listView.implicitHeight + addItemRectangle.height
        transformOrigin: Item.Top
        margins: 0

        Material.theme: control.Material.theme
        Material.accent: control.Material.accent
        Material.primary: control.Material.primary

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        onOpened: listView.positionViewAtBeginning();

        contentItem: Column {
            width: parent.width
            height: parent.height

            ListView {
                id: listView
                focus: true
                clip: true
                width: parent.width
                implicitHeight: contentHeight
                height: parent.height - addItemRectangle.height
                highlightMoveDuration: 0
                keyNavigationEnabled: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalAndVerticalFlick

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }

                delegate: ItemDelegate {
                    function selectItem() {
                        control.text = text
                        control.manuallyModified = true
                        control.selectedId = idRole(model)
                        listView.currentIndex = index
                        popup.close()
                        control.nextItemInFocusChain().forceActiveFocus()
                    }

                    text: textRole(model)
                    width: parent.width
                    highlighted: index === listView.currentIndex
                    font.pixelSize: Units.fontSizeCaption
                    font.family: "Roboto Regular"

                    Keys.onReturnPressed: selectItem()
                    Keys.onEnterPressed: selectItem()

                    // We use a MouseArea because we don't want the clicked() signal
                    // to be emitted when the user enters a space in the TextField.
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectItem();
                    }
                }
            }

            Rectangle {
                id: addItemRectangle
                visible: control.showAddItem
                implicitHeight: visible ? addItemDelegate.implicitHeight : 0
                width: parent.width
                color: "white"
                z: 5
                focus: true

                ItemDelegate {
                    id: addItemDelegate
                    text: control.addItemText
                    width: parent.width
                    leftPadding: addItemIcon.width + Units.smallSpacing
                    z: 3
                    focus: true
                    background.opacity: 1

                    Material.background: "white"

                    Label {
                        id: addItemIcon
                        leftPadding: Units.smallSpacing
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\ue147"
                        font.family: "Material Icons"
                        font.pixelSize: Units.fontSizeHeadline
                        Material.foreground: Material.accent
                    }

                    onClicked: addItemClicked()
                }
            }
        }
    }
}
