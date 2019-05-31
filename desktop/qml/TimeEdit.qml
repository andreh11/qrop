import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

MyTextField {
    id: laborTimeField

    function reset() {
        text = "00:00";
    }

    function selectHours() {
        cursorPosition = 0;
        select(0,2);
    }

    function selectMinutes() {
        cursorPosition = 3;
        select(3,5);
    }

    floatingLabel: true
    inputMethodHints: Qt.ImhTime
    errorText: qsTr("Enter a valid time format (HH:MM)")
    hasError: !acceptableInput
    inputMask: "00:00"
    text: "00:00"
    validator: TimeValidator { }
    suffixText: qsTr("h", "Abbreviaton for hour")

    onActiveFocusChanged: {
        if (!activeFocus)
            return;
        if (focusReason === Qt.BacktabFocusReason)
            selectMinutes();
        else
            selectHours();
    }

    Keys.onTabPressed: {
        if (cursorPosition <= 3)
            selectMinutes();
        else
            event.accepted = false;
    }

    Keys.onBacktabPressed: {
        if (cursorPosition >= 3)
            selectHours();
        else
            event.accepted = false;
    }
}
