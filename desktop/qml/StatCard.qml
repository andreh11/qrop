import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

Pane {
    Material.elevation: 1

    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text
    property alias text: textLabel.text

    Label {
        id: titleLabel
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        color: Units.colorMediumEmphasis
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 4
            topMargin: 4
        }
    }

    Label {
        id: subtitleLabel
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeCaption
        color: Units.colorMediumEmphasis
        anchors {
            left: parent.left
            top: titleLabel.bottom
            leftMargin: 4
            topMargin: 2
        }
    }

    
    Label {
        id: textLabel
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeHeadline
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: Units.colorHighEmphasis
        
        anchors {
//            top: titleLabel.bottom
            left: parent.left
            bottom: parent.bottom
            leftMargin: 4

        }
    }
}
