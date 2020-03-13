import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

// TODO: refactor
Label {
    font.family: "Roboto Regular"
    font.pixelSize: largeDisplay ? Units.fontSizeBodyAndButton : Units.fontSizeCaption
    topPadding: Units.mediumSpacing
    leftPadding: largeDisplay ? 0 : Units.mediumSpacing
    color: largeDisplay ? Units.colorHighEmphasis : Material.accent
}
