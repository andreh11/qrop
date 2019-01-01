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

Page {
    title: qsTr("Settings")

    Column {
        width: parent.width * 0.8
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Units.smallSpacing
        topPadding: Units.smallSpacing
        bottomPadding: topPadding

        Pane {
            width: parent.width
            Material.elevation: 2

            Label {
                text: qsTr("Settings")
                anchors.centerIn: parent
            }
        }

        Pane {
            width: parent.width
            Material.elevation: 2

            Label {
                text: qsTr("Settings")
                anchors.centerIn: parent
            }
        }

        Pane {
            width: parent.width
            Material.elevation: 2

            Label {
                text: qsTr("Settings")
                anchors.centerIn: parent
            }
        }
    }
}
