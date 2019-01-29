import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform
import QtQuick.Window 2.10

import io.croplan.components 1.0
import "date.js" as MDate

Label {
    id: backIcon
    text: "\ue5c4" // arrow_back
    color: Material.color(Material.Grey)
    font.family: "Material Icons"
    font.pixelSize: Units.fontSizeHeadline
}
