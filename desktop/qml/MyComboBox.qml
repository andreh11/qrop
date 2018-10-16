import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.croplan.components 1.0

ComboBox {
    id: control
    Material.elevation: 0
    width: parent.width
//    height: 56
    padding: 0

    property string labelText: ""
    property string helperText: ""
    property string prefixText: ""
    property string suffixText: ""
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
//        else
//            select(0, 0);
    }

    Label {
        id: fieldLabel
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.labelText
        font: control.contentItem.font
        color: control.contentItem.Material.hintTextColor
        verticalAlignment: control.contentItem.verticalAlignment
        elide: Text.ElideRight
        renderType: control.contentItem.renderType
        visible: !control.contentItem.length
    }

    Label {
        id: floatingLabel
        anchors.top: control.top
        anchors.topMargin: -2
        anchors.left: parent.left
        color: Material.accent
        text: labelText
        font.pixelSize: 14
        visible: control.contentItem.text !== ""
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: control.bottom
            topMargin: -2
        }

        Label {
            id: helperTextLabel
            visible: control.helperText
            text: acceptableInput ? control.helperText : qsTr("Bad input")
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
