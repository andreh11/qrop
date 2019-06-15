import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as Platform

import io.qrop.components 1.0

Item {
    id: control

    property alias text: textField.text
    property alias inputMethodHints: textField.inputMethodHints
    property alias validator: textField.validator
    property alias horizontalAlignment: textField.horizontalAlignment

    signal editingFinished()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: true
        onDoubleClicked: control.state = "edit"
    }

    Label {
        id: label
        elide: Text.ElideRight
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        text: control.text
        anchors.verticalCenter: parent.verticalCenter
    }

    TextField {
        id: textField

        property string oldText: ""

        visible: false
        font.family: "Roboto Regular"
        font.pixelSize: Units.fontSizeBodyAndButton
        anchors.verticalCenter: parent.verticalCenter

        onVisibleChanged: if (visible) forceActiveFocus();
        onActiveFocusChanged: oldText = text

        onEditingFinished: {
            control.state = "display";
            control.editingFinished();
        }

        Keys.onEscapePressed: {
            text = oldText;
            control.state = "display";
        }
    }

    state: "display"
    states: [
        State {
            name: "display"
            PropertyChanges {
                target: label
                visible: true
            }
            PropertyChanges {
                target: textField
                visible: false
            }
            PropertyChanges {
                target: textField
                visible: false
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: label
                visible: false
            }
            PropertyChanges {
                target: textField
                visible: true
            }
        }
    ]
}
