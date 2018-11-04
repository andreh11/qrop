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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.0

import io.croplan.components 1.0

ComboBox {
    id: control

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

    Material.elevation: 0
    width: parent.width
    //    height: 56
    padding: 0

    onActiveFocusChanged: {
        if (activeFocus && (focusReason === Qt.TabFocusReason
                            || focusReason === Qt.BacktabFocusReason)) {
            if (editable)
                selectAll();
            else
                popup.open();
        }
    }

    popup:  Popup {
        y: control.editable ? control.height - 5 : 0
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
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
            if (listView.model.count === 0 && showAddItem) {
                // Ensure footer is visible
                listView.contentY = listView.contentHeight
            }
        }

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0

            ScrollIndicator.vertical: ScrollIndicator { }
            footerPositioning: ListView.OverlayHeader

            Component {
                id: addItemDelegate
                ItemDelegate {
                    text: control.addItemText
                    width: parent.width
                    leftPadding: addItemIcon.width + Units.smallSpacing
                    z: 3
                    focus: true

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

            footer: showAddItem ? addItemDelegate : null
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
        visible: !control.contentItem.length
    }

    Label {
        id: floatingLabel
        anchors.top: control.top
        anchors.topMargin: -2
        anchors.left: parent.left
        color: Material.accent
        text: labelText
        font.pixelSize: 14
        visible: control.contentItem.text !== ""
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
                ColorAnimation { duration: 200 }
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
                ColorAnimation { duration: 200 }
            }
        }
    }
}
