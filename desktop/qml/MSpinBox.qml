import QtQuick 2.9
import QtQuick.Controls 2.2

SpinBox {
    property string prefix: ""
    property string suffix: ""

    textFromValue: function(value, locale) {
        return (qsTr(prefix) + "%1" + qsTr(suffix)).arg(value)
    }
}
