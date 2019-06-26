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

import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.3

Pane {
    id: photoPane
    
    property var photoIdList
    padding: 0
    
    onPhotoIdListChanged: {
        photoModel.clear();
        for (var i = 0; i< photoIdList.length; i++) {
            photoModel.append({"photoId": photoIdList[i]})
        }
    }
    
    ListModel {
        id: photoModel
    }

    ToolButton {
        id: closeButton
        text: "\ue14c"
        font.family: "Material Icons"
        font.pixelSize: Units.fontSizeHeadline
        onClicked: photoPane.visible = false
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16 -padding
        Material.foreground: Units.closeButtonColor
    }

    SwipeView {
        id: swipeView
        anchors {
            top: closeButton.bottom
            left: parent.left
            right: parent.right
            bottom: indicator.top
            margins: Units.largeSpacing
        }

        clip: true
        currentIndex: indicator.currentIndex
//        transitions: null
        Repeater {
            model: photoModel
            Loader {
                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                sourceComponent:
                    Image {
                    anchors.centerIn: parent
                    width: 200
                    height: width
                    source: "image://pictures/" + photoId
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }

    RoundButton {
        id: backButton
        text: "\ue408" // arrow_back
        Material.foreground: Material.Grey
        font.family: "Material Icons"
        font.pixelSize: Units.fontSizeHeadline
        anchors.verticalCenter: swipeView.verticalCenter
        anchors.left: swipeView.left
        onClicked: swipeView.decrementCurrentIndex()
    }

    RoundButton {
        id: nextButton
        text: "\ue409" // arrow_back
        Material.foreground: Material.Grey
        font.family: "Material Icons"
        font.pixelSize: Units.fontSizeHeadline
        anchors.verticalCenter: swipeView.verticalCenter
        anchors.right: swipeView.right
        onClicked: swipeView.incrementCurrentIndex()
    }

    PageIndicator {
        id: indicator
        
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        interactive: true
        
        anchors {
            bottom: parent.bottom
            bottomMargin: Units.formSpacing
            horizontalCenter: parent.horizontalCenter
        }
    }
}
