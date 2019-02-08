import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.10

import io.qrop.components 1.0
import "date.js" as MDate

Pane {
    id: photoPane
    
    property var photoIdList
    
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
        text: "\ue14c"
        font.family: "Material Icons"
        font.pixelSize: Units.fontSizeHeadline
        onClicked: photoPane.visible = false
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: -padding
    }

    SwipeView {
        id: swipeView
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.9
        transitions: null
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
        
        anchors.top: swipeView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
