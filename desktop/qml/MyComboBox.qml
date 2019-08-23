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

import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.0

import io.qrop.components 1.0

ComboBox {
    id: control

    property bool manuallyModified

    property int rowId: -1
    property string labelText: ""
    property string helperText: ""
    property string prefixText: ""
    property string suffixText: ""
    property string errorText: qsTr("Bad input")
    property bool persistentPrefix: false
    property bool persistentSuffix: false

    property bool showAddItem: false
    property string addItemText: qsTr("Add Item")

    property bool floatingLabel: false
    property bool hasError: (characterLimit && length > characterLimit) || !acceptableInput
    property int characterLimit
    property bool showBorder: true
    property color placeholderTextColor
    property int suffixTextAddedMargin: 0

    property color color: Material.accent
    property color errorColor: Material.color(Material.red, Material.Shade500)
    property color hintColor: shade(0.38)

    signal addItemClicked()

    function shade(alpha) {
        return Qt.rgba(0,0,0,alpha)
    }

    function reset() {
        manuallyModified = false;
        currentIndex = -1;
    }

    function setRowId(id) {
        var i = 0;
        while (model.rowId(i) !== id && i < model.rowCount)
            i++;
        if (i < model.rowCount)
            currentIndex = i;
    }
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)

//    implicitWidth: Math.max(background ? background.implicitWidth : 0,
//                            leftPadding + rightPadding)
//                            || contentWidth + leftPadding + rightPadding
//    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
//                             background ? background.implicitHeight : 0,
//                             topPadding + bottomPadding)

    onRowIdChanged: setRowId(rowId)

    Material.elevation: 0
    width: parent.width
    padding: 0
    editable: true

    onEditTextChanged: {
        if (activeFocus) {
            popup.open()
            control.forceActiveFocus()
        }
    }

    onPressedChanged: manuallyModified = true
    onActiveFocusChanged: {
        if (activeFocus && (focusReason === Qt.TabFocusReason
                            || focusReason === Qt.BacktabFocusReason)) {
            if (editable)
                selectAll();
            else
                popup.open();
        }
    }

    background: Rectangle {
        height: 32
        implicitWidth: 200
        implicitHeight: 40
        border.width: control.activeFocus ? 2 : 1
        radius: 4
        color: control.palette.base
        border.color: control.activeFocus ? control.palette.highlight : control.palette.mid
    }

    Label {
        id: floatingLabel
        anchors.bottom: control.top
        anchors.left: parent.left
//        anchors.topMargin: -2
        color: Material.accent
        text: labelText
        font.pixelSize: 14
        visible: labelText
    }

    popup: Popup {
        id: popup
        y: control.editable ? control.height - 5 : 0
        width: control.width
        height: ApplicationWindow.window
                ? Math.min(listView.implicitHeight + addItemRectangle.height, ApplicationWindow.window.height - topMargin - bottomMargin)
                : listView.implicitHeight + addItemRectangle.height
        transformOrigin: Item.Top
        topMargin: 12
        bottomMargin: 12
        padding: 0

        Material.theme: control.Material.theme
        Material.accent: control.Material.accent
        Material.primary: control.Material.primary

        enter: Transition {
            // grow_fade_in
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        exit: Transition {
            // shrink_fade_out
            NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
        }

        onOpened: {
                listView.positionViewAtBeginning();
        }

        contentItem: Column {
            width: parent.width
            height: parent.height
            ListView {
                id: listView
                focus: true
                clip: true
                currentIndex: control.highlightedIndex
                width: parent.width
                implicitHeight: contentHeight
                height: parent.height - addItemRectangle.height

                model: control.delegateModel
                highlightMoveDuration: 0
                keyNavigationEnabled: true
                keyNavigationWraps: true

                Keys.priority: Keys.AfterItem

//                Shortcut {
//                    sequence: "Down"
//                    enabled: listView.visible && listView.currentIndex === listView.count - 1 && showAddItem
//                    context: Qt.ApplicationShortcut
//                    onActivated: addItemRectangle.forceActiveFocus();
//                }

                ScrollBar.vertical: ScrollBar { }

                delegate: ItemDelegate {
                    text: modelData
                    font.pixelSize: Units.fontSizeBodyAndButton
                    font.family: "Robo Regular"
                    width: parent.width
                }
        }

        Rectangle {
            id: addItemRectangle
            visible: showAddItem
            implicitHeight: visible ? addItemDelegate.implicitHeight : 0
            width: parent.width
            color: "white"
            z: 5
            focus: true
//            anchors.bottom: parent.bottom

            ItemDelegate {
                id: addItemDelegate
                text: control.addItemText
                width: parent.width
                leftPadding: addItemIcon.width + Units.smallSpacing
                z: 3
                focus: true
                Material.background: "white"
                background.opacity: 1

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

    Label {
        id: fieldLabel
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.labelText
        font: control.contentItem.font
        color: control.contentItem.Material.hintTextColor
        verticalAlignment: control.contentItem.verticalAlignment
        elide: Text.ElideRight
        renderType: control.contentItem.renderType
//        visible: !control.contentItem.length
        leftPadding: 10
        visible: false
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
            topMargin: -2
        }

        Label {
            id: helperTextLabel
            visible: control.helperText
            text: acceptableInput ? control.helperText : control.errorText
            font.pixelSize: 12
            color: control.hasError ? control.errorColor
                                    : Qt.darker(control.hintColor)

            Behavior on color {
                ColorAnimation { duration: Units.mediumDuration }
            }
        }

        Label {
            id: charLimitLabel
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            visible: control.characterLimit && control.showBorder
            text: control.length + " / " + control.characterLimit
            font.pixelSize: 12
            color: control.hasError ? control.errorColor : control.hintColor
            horizontalAlignment: Text.AlignLeft

            Behavior on color {
                ColorAnimation { duration: Units.mediumDuration }
            }
        }
    }
}
