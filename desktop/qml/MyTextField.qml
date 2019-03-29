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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

TextField {
    id: control

    property bool manuallyModified: false

    property string helperText
    property string labelText: ""
    property string prefixText: ""
    property string suffixText: ""
    property string errorText: qsTr("Error")
    property bool persistentPrefix: false
    property bool persistentSuffix: false
    property bool floatMode: false
    property bool showError: false
    property bool floatingLabel: false
    property bool hasError: showError && ((characterLimit && length > characterLimit) || !acceptableInput)
    property int characterLimit
    property bool showBorder: true
    property bool autoJumpToNextItem: true
    property int suffixTextAddedMargin: Units.smallSpacing

    property color color: manuallyModified ? "red" : Material.accent
    property color errorColor: Material.color(Material.red, Material.Shade500)
    property color hintColor: shade(0.38)

    function shade(alpha) {
        return Qt.rgba(0,0,0,alpha)
    }

    function reset() {
        clear();
        manuallyModified = false;
    }

    onAccepted: if (autoJumpToNextItem) nextItemInFocusChain().forceActiveFocus()

    onActiveFocusChanged: {
        if (activeFocus)
            selectAll();
        else
            select(0, 0);
    }

    onTextEdited: {
        floatMode = true
        manuallyModified = true
    }

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             topPadding + bottomPadding)

    leftPadding: Units.smallSpacing
    rightPadding: leftPadding

    activeFocusOnPress: true
    activeFocusOnTab: true

    Keys.onEscapePressed: event.accepted = false
    Layout.minimumWidth: 120

    background: Rectangle {
        height: 32
        implicitWidth: 200
        implicitHeight: 40
        border.width: control.activeFocus ? 2 : 1
        radius: 4
        color: control.palette.base
        border.color: control.activeFocus ? control.palette.highlight : control.palette.mid
        Behavior on border.color {
            ColorAnimation { duration: Units.mediumDuration }
        }
    }

    Label {
        id: floatingLabel
        anchors.bottom: control.top
        anchors.left: parent.left
        color: parent.enabled ? Material.accent : parent.Material.hintTextColor
        text: labelText
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: labelText
    }

    Label {
        id: prefixText
        text: control.prefixText
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: persistentPrefix || (control.prefixText !== "" && control.text != "")
        anchors {
            left: parent.left
            leftMargin: 0
            bottomMargin: 16
            bottom: parent.bottom
        }
    }

    Label {
        id: suffixText
        text: control.suffixText
        anchors.right: parent.right
        anchors.rightMargin: suffixTextAddedMargin
        anchors.bottomMargin: 16
        anchors.bottom: parent.bottom
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: persistentSuffix || (control.suffixText !== "" && control.text != "")
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
            topMargin: -6
        }

        Label {
            id: helperTextLabel
            visible: control.helperText
            text: hasError ? control.errorText : control.helperText
            font.pixelSize: 12
            color: control.hasError ? control.errorColor
                                    : Material.color(Material.Grey, Material.Shade800)

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

            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
