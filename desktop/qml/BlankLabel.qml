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

import QtQuick 2.11
import QtQuick.Controls 2.4

Column {
    id: column
    property alias primaryText: primaryLabel.text
    property alias secondaryText: secondaryLabel.text
    property alias primaryButtonText: primaryButton.text
    property alias highlightPrimaryButton: primaryButton.highlighted

    signal primaryButtonClicked()

    Label {
        id: primaryLabel
        color: Units.colorHighEmphasis
        font.pixelSize: Units.fontSizeTitle
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        
    }

    Label {
        id: secondaryLabel
        visible: secondaryText
        color: Units.colorMediumEmphasis
        font.pixelSize: Units.fontSizeSubheading
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    FlatButton {
        id: primaryButton
        visible: text
        highlighted: true
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Units.fontSizeBodyAndButton
        onClicked: column.primaryButtonClicked()
    }
}
