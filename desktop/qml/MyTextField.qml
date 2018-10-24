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

    property string labelText: ""
    property string prefixText: ""
    property string suffixText: ""
    property string errorText: qsTr("Error")
    property bool persistentPrefix: false
    property bool persistentSuffix: false

    property bool floatingLabel: false
    property bool hasError: (characterLimit && length > characterLimit) || !acceptableInput
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
        id: fieldLabel
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.labelText
        font: control.font
        color: control.Material.hintTextColor
        verticalAlignment: control.verticalAlignment
        elide: Text.ElideRight
        renderType: control.renderType
        visible: !control.text
    }

    Label {
        id: floatingLabel
        anchors.verticalCenter: control.top
        anchors.left: parent.left
        color: Material.accent
        text: labelText
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: control.text != ""
    }

    Label {
        id: prefixText
        text: control.prefixText
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.bottomMargin: 16
        anchors.bottom: parent.bottom
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: persistentPrefix || (control.prefixText !== "" && control.text != "")
    }

    Label {
        id: suffixText
        text: control.suffixText
        anchors.right: parent.right
        anchors.rightMargin: suffixTextAddedMargin
        anchors.bottomMargin: 16
        anchors.bottom: parent.bottom
        font.pixelSize: Units.fontSizeBodyAndButton
        visible: persistentSuffix || (control.suffixText !== "" && control.text != "")
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
        }

        Label {
            id: helperTextLabel
            visible: control.helperText
            text: acceptableInput ? control.helperText : control.errorText
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

//    leftPadding: 8

//    Rectangle { anchors.bottom: parent.background.bottom
//        height: 46
//        width: parent.width
//        z: -10
//        color: Material.color(Material.Grey, Material.Shade100)
//        radius: 4
//    }
}
