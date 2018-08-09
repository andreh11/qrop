import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

ComboBox {
    id: plantingMethodCombo
    Material.elevation: 0
    width: parent.width
    padding: 0
    background: Rectangle {
        id: underline
        color: "transparent"
        radius: 4
        implicitHeight: 40
        implicitWidth: 120
        border.color: plantingMethodCombo.activeFocus ? Material.color(Material.accent)
                                                      : Material.color(Material.Grey)
        border.width: plantingMethodCombo.activeFocus ? 2 : 1
        height: parent.height
        visible: true
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        
        Behavior on height {
            NumberAnimation { duration: 200 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
}
