import QtQuick 2.4
import QtQuick.Controls 1.4

import io.croplan.components 1.0

PlantingForm {
    cropField.model: CropModel {}
    cropField.textRole: "name"
}
