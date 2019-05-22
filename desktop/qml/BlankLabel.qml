import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtCharts 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Column {
    property alias primaryText: primaryLabel.text
    property alias secondaryText: secondaryLabel.text

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
}
