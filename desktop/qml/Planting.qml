import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import io.croplan.components 1.0

ScrollView {
    anchors.fill: parent
PlantingForm {
    width: parent.width
    Layout.fillWidth: true
    cropField.model: CropModel {}
    cropField.textRole: "name"
}
}
