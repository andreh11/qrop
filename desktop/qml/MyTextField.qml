import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import QtCharts 2.0

import io.croplan.components 1.0

TextField {
    id: control

    property string helperText

    property string prefixText: ""
    property string suffixText: ""
    property bool persistentPrefix: false
    property bool persistentSuffix: false

    property bool floatingLabel: false
    property bool hasError: characterLimit && length > characterLimit
    property int characterLimit
    property bool showBorder: true
    property color placeholderTextColor
    property int suffixTextAddedMargin: 0

    property color color: Material.accent
    property color errorColor: Material.color(Material.red, Material.Shade500)
    property color hintColor: shade(0.38)

    function shade(alpha) {
        return Qt.rgba(0,0,0,alpha)
    }

    onActiveFocusChanged: {
        if (activeFocus && (focusReason === Qt.TabFocusReason | Qt.BacktabFocusReason))
            selectAll();
        else
            select(0, 0);
    }

    Label {
        id: flatingLabel
        anchors.verticalCenter: control.top
        color: Material.accent
        text: placeholderText
        font.pixelSize: 14
        visible: control.text != ""
    }

    Label {
        id: prefixText
        text: control.prefixText
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.bottomMargin: 16
        anchors.bottom: parent.bottom
        font.pixelSize: 14
        visible: persistentPrefix || (control.prefixText !== "" && control.text != "")
    }

    Label {
        id: suffixText
        text: control.suffixText
        anchors.right: parent.right
        anchors.rightMargin: 14 + suffixTextAddedMargin
        anchors.bottomMargin: 16
        anchors.bottom: parent.bottom
        font.pixelSize: 14
        visible: persistentSuffix || (control.suffixText !== "" && control.text != "")
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
            //                leftMargin: 14
            //                topMargin: 4
        }

        Label {
            id: helperTextLabel
            visible: control.helperText
            text: control.helperText
            font.pixelSize: 12
            color: control.hasError ? control.errorColor
                                    : Qt.darker(control.hintColor)

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }

        Label {
            id: charLimitLabel
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            visible: control.characterLimit && control.showBorder
            text: control.length + " / " + control.characterLimit
            font.pixelSize: 12
            color: control.hasError ? control.errorColor : control.hintColor
            horizontalAlignment: Text.AlignLeft

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }
}
