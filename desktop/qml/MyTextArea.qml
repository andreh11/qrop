import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

TextArea {
    id: control

    property string labelText: ""
    property bool manuallyModified: false

    function shade(alpha) {
        return Qt.rgba(0,0,0,alpha)
    }

    function reset() {
        clear();
        manuallyModified = false;
    }

    onActiveFocusChanged: {
        if (activeFocus)
            selectAll();
        else
            select(0, 0);
    }

    leftPadding: Units.smallSpacing
    rightPadding: leftPadding

    Label {
        id: floatingLabel
        anchors.bottom: control.top
        anchors.left: parent.left
        color: parent.enabled ? Material.accent : parent.Material.hintTextColor
        text: labelText
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: labelText
    }

    background: Rectangle {
        //                    height: 32
        implicitWidth: 200
        implicitHeight: 40
        border.width: control.activeFocus ? 2 : 1
        radius: 4
        color: control.palette.base
        border.color: control.activeFocus ? control.palette.highlight : control.palette.mid
        Behavior on border.color {
            ColorAnimation { duration: Units.mediumDuration }
        }
    }
}
