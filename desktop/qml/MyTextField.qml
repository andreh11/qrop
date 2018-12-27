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

import io.croplan.components 1.0

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
//    property color placeholderTextColor
    property int suffixTextAddedMargin: 0

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

    activeFocusOnPress: true
    activeFocusOnTab: true
    Layout.minimumWidth: 120
    background.width: width

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

    onAccepted: nextItemInFocusChain().forceActiveFocus()

    Label {
        id: fieldLabel
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.labelText
        font: control.font
        color: control.Material.hintTextColor
        verticalAlignment: control.verticalAlignment
        elide: Text.ElideRight
        renderType: control.renderType
        visible: !control.text && !activeFocus
    }

    Label {
        id: floatingLabel
        anchors.verticalCenter: control.top
        anchors.left: parent.left
        color: Material.accent
        text: labelText
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: control.text != "" || activeFocus
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

            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
