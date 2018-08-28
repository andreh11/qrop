import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import QtCharts 2.0

import io.croplan.components 1.0

TextField {
    id: control
    property color color: Material.accent
    property color errorColor: Material.color(Material.red, Material.Shade500)
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

    onActiveFocusChanged: {
        if (activeFocus && (focusReason === Qt.TabFocusReason | Qt.BacktabFocusReason))
            selectAll();
        else
            select(0, 0);
    }

    QtObject {
        id: palette

        property bool light

        readonly property color textColor: light ? shade(0.87) : shade(1)
        readonly property color subTextColor: light ? shade(0.54) : shade(0.70)
        readonly property color iconColor: light ? subTextColor : textColor
        readonly property color disabledColor: light ? shade(0.38) : shade(0.50)
        readonly property color hintColor: disabledColor
        readonly property color dividerColor: shade(0.12)

        function shade(alpha) {
            if (light) {
                return Qt.rgba(0,0,0,alpha)
            } else {
                return Qt.rgba(1,1,1,alpha)
            }
        }
    }

    topPadding: 14
    bottomPadding: topPadding
    rightPadding: topPadding + (suffixText.visible ? suffixText.width + 8 : 0)
    leftPadding: topPadding + (prefixText.visible ? prefixText.width + 8 : 0)

    font {
        family: echoMode == TextInput.Password ? "Default" : "Roboto Regular"
        pixelSize: fontSizeBodyAndButton
    }

    renderType: Text.QtRendering
    placeholderTextColor: "transparent"
    selectedTextColor: "white"
    selectionColor: control.hasOwnProperty("color") ? control.color : Material.accent
    //    textColor: Theme.light.textColor

    background : Item {
        id: background
        implicitWidth: Math.max(250, control.width)

        property color color: control.hasOwnProperty("color") ? control.color : Material.accent
        property color errorColor: control.hasOwnProperty("errorColor")
                                   ? control.errorColor : Material.color(Material.red, Material.Shade500)
        property string helperText: control.hasOwnProperty("helperText") ? control.helperText : ""
        property bool floatingLabel: control.hasOwnProperty("floatingLabel") ? control.floatingLabel : ""
        property bool hasError: control.hasOwnProperty("hasError")
                                ? control.hasError : characterLimit && control.length > characterLimit
        property int characterLimit: control.hasOwnProperty("characterLimit") ? control.characterLimit : 0
        property bool showBorder: control.hasOwnProperty("showBorder") ? control.showBorder : true

        Rectangle {
            id: underline
            color: "transparent"
            radius: 4
            border.color: background.hasError ? background.errorColor
                                       : (control.activeFocus ? background.color
                                                             : Material.color(Material.Grey))

            border.width: control.activeFocus ? 2 : 1
            height: control.height
            visible: background.showBorder
            width: control.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4

            Behavior on height {
                NumberAnimation { duration: 200 }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
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
            anchors.rightMargin: 14
            anchors.bottomMargin: 16
            anchors.bottom: parent.bottom
            font.pixelSize: 14
            visible: persistentSuffix || (control.suffixText !== "" && control.text != "")
        }

        Label {
            id: fieldPlaceholder

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: underline.left
            anchors.leftMargin: 14
            text: control.placeholderText
            font.pixelSize: 16
            visible: control.text != ""

            background: Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 4
                width: parent.width + 8
                color: "white"
            }

            color: background.hasError ? background.errorColor
//                                       : control.activeFocus && control.text !== ""
                                       : control.text == "" || !control.activeFocus
                                         ? Material.color(Material.Grey) : background.color

//                                         ? background.color : palette.hintColor

            states: [
                State {
                    name: "floating"
//                    when: control.displayText.length > 0 && background.floatingLabel
                    when: background.floatingLabel && (control.activeFocus || (control.displayText.length > 0))
                    AnchorChanges {
                        target: fieldPlaceholder
                        anchors.verticalCenter: underline.top
                    }
                    PropertyChanges {
                        target: fieldPlaceholder
                        font.pixelSize: 12
                    }
                },
                State {
                    name: "hidden"
                    when: control.displayText.length > 0 && !background.floatingLabel
                    PropertyChanges {
                        target: fieldPlaceholder
                        visible: false
                    }
                }
            ]

            transitions: [
                Transition {
                    id: floatingTransition
                    from: ""
                    to: "floating"
                    enabled: false
                    reversible: true
                    AnchorAnimation {
                        duration: 100
                    }
                    NumberAnimation {
                        duration: 100
                        property: "font.pixelSize"
                    }
                }
            ]

            Component.onCompleted: floatingTransition.enabled = true
        }

        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                top: underline.bottom
                leftMargin: 14
                topMargin: 4
            }

            Label {
                id: helperTextLabel
                visible: background.helperText && background.showBorder
                text: background.helperText
                font.pixelSize: 12
                color: background.hasError ? background.errorColor
                                           : Qt.darker(palette.hintColor)

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                property string helperText: control.hasOwnProperty("helperText")
                                            ? control.helperText : ""
            }

            Label {
                id: charLimitLabel
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                visible: background.characterLimit && background.showBorder
                text: control.length + " / " + background.characterLimit
                font.pixelSize: 12
                color: background.hasError ? background.errorColor : palette.hintColor
                horizontalAlignment: Text.AlignLeft

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
