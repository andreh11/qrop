/*
 * Copyright (C) 2019 André Hoarau <ah@ouvaton.org>
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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

Pane {
    id: pane

    property int firstColumnWidth: 200
    property int secondColumnWidth: 150

    signal close();

    Material.elevation: 2
    Material.background: "white"
    padding: 0

    RowLayout {
        id: rowLayout
        spacing: Units.smallSpacing
        width: parent.width

        ToolButton {
            id: drawerButton
            text: "\ue5c4"
            font.family: "Material Icons"
            font.pixelSize: Units.fontSizeHeadline
            onClicked: pane.close()
            Layout.leftMargin: Units.formSpacing
        }

        Label {
            id: familyLabel
            text: qsTr("Families and crops")
            font.family: "Roboto Regular"
            font.pixelSize: Units.fontSizeSubheading
            Layout.fillWidth: true
        }

        Button {
            text: qsTr("Add family")
            flat: true
            Material.foreground: Material.accent
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.rightMargin: Units.mediumSpacing

            onClicked: addFamilyDialog.open()

            AddFamilyDialog {
                id: addFamilyDialog
                onAccepted: {
                    Family.add({"family" : cropName, "color" : color});
                    familyModel.refresh();
                }
            }
        }
    }

    ListView {
        id: familyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        clip: true

        anchors {
            top: rowLayout.bottom
            topMargin: Units.mediumSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: scrollBar }

        spacing: Units.smallSpacing
        model: FamilyModel { id: familyModel }
        delegate: SettingsFamilyDelegate {
            width: parent.width
            onRefresh: familyModel.refresh()
            firstColumnWidth: pane.firstColumnWidth
            secondColumnWidth: pane.secondColumnWidth
        }
    }
}
