import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0

import io.qrop.components 1.0

RowLayout {
    id: control
    property alias text: label.text
    property alias checked: _switch.checked

    signal toggled()

    width: parent.width
    Layout.leftMargin: Units.mediumSpacing
    Layout.rightMargin: Layout.leftMargin
    
    Label {
        id: label
        Layout.fillWidth: true
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        
    }
    
    Switch {
        id: _switch
        onToggled: control.toggled();
    }
}
