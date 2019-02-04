import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

Rectangle {
    id: textIcon

    property int cropId
    property string cropName: {
        var map = Crop.mapFromId("crop", cropId);
        return map['name'];
    }

    property color cropColor: {
        var map = Crop.mapFromId("crop", cropId);
        return map['color'];
    }

    height: 40
    width: height
    radius: 80
    color: Material.color(Material.Green, Material.Shade400)
    
    Text {
        anchors.centerIn: parent
        text: cropField.currentText.slice(0,2)
        color: "white"
        font { family: "Roboto Regular"; pixelSize: 24 }
    }
}
