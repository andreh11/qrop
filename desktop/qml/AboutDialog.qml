/*
 * Copyright (C) 2018−2019 André Hoarau <ah@ouvaton.org>
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

Dialog {
    id: root
    modal: true
    focus: true
    title: qsTr("About Qrop")
    contentHeight: aboutColumn.height
    
    Row {
        spacing: Units.mediumSpacing
        
        Column {
            id: aboutColumn
            spacing: Units.mediumSpacing
            width: root.availableWidth -  2 * Units.smallSpacing
            
            Image {
                id: image
                source: "/icon.png"
                width: 100
                height: width
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter:  parent.horizontalCenter
            }
            
            Label {
                width: parent.width
                text: "Qrop"
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize:  Units.fontSizeHeadline
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: "v%1 (%2/%3)".arg(BuildInfo.version).arg(BuildInfo.commit).arg(BuildInfo.branch)
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize:  Units.fontSizeBodyAndButton
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: qsTr("A cross-platform tool for crop planning and recordkeeping. Made by farmers, for farmers with the help of the French coop <a href='https://latelierpaysan.org'>L'Atelier paysan</a>.")
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeBodyAndButton
                onLinkActivated: Qt.openUrlExternally(link)
                horizontalAlignment: Text.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            
            
            Label {
                width: parent.width
                text: "Copyright © 2018−2020, André Hoarau"
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeCaption
                horizontalAlignment: Text.AlignHCenter
            }
            
            Label {
                width: parent.width
                text: qsTr("This program comes with ABSOLUTELY NO WARRANTY, for more details, visit <a href='https://www.gnu.org/licenses/gpl-3.0.html'>GNU General Public License version 3</a>.")
                font.family: "Roboto Regular"
                wrapMode: Label.Wrap
                font.pixelSize: Units.fontSizeCaption
                horizontalAlignment: Text.AlignHCenter
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            
        }
    }
}
