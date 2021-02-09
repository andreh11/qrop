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
    property int paneWidth

    signal close();

    function refresh() {
//        familyModel.refresh();
    }

    Material.elevation: 0
    Material.background: Units.pageColor
    padding: 0
    anchors.fill: parent

    Pane {
        id: backgroundPane
        Material.background: "white"
        Material.elevation: 1
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: paneWidth
    }

    ListView {
        id: familyView
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        clip: true

        ScrollBar.vertical: ScrollBar {
            parent: pane
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        }
        cacheBuffer: Units.rowHeight * 20

        anchors.fill: parent
        header:  RowLayout {
            id: rowLayout
            spacing: Units.smallSpacing
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter

            ToolButton {
                id: drawerButton
                text: "\ue5c4"
                Material.foreground:  Units.colorHighEmphasis
                font.family: "Material Icons"
                font.pixelSize: Units.fontSizeHeadline
                onClicked: pane.close()
                Layout.leftMargin: Units.formSpacing
            }

            Label {
                id: familyLabel
                text: qsTr("Families and crops")
                font.family: "Roboto Regular"
                color: Units.colorHighEmphasis
                font.pixelSize: Units.fontSizeBodyAndButton
                Layout.fillWidth: true
            }

            FlatButton {
                text: qsTr("Add family")
                highlighted: true
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

        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()

        spacing: 0
        model: cppFamily.modelFamily()
//        model: FamilyProxyModel {
//            id: familyModel
//            qrop: cppQrop
//        }
        delegate: SettingsFamilyDelegate {
            width: paneWidth
            anchors.horizontalCenter: parent.horizontalCenter
//            onRefresh: familyModel.refreshRow(index)
            firstColumnWidth: pane.firstColumnWidth
            secondColumnWidth: pane.secondColumnWidth
        }
    }
}
