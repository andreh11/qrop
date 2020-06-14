import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.0

import io.qrop.components 1.0

ColumnLayout {
    property alias title: titleLabel.text
    property alias text: textLabel.text
    Label {
        id: titleLabel
        font { family: "Roboto Regular"; pixelSize: Units.fontSizeCaption }
        color: Qt.rgba(0,0,0, 0.50)
        Layout.alignment: Qt.AlignRight
    }

    Label {
        id: textLabel
        horizontalAlignment: Text.AlignHCenter
        font { family: "Roboto Regular"; pixelSize: Units.fontSizeBodyAndButton }
        color: Qt.rgba(0,0,0, 0.87)
        Layout.alignment: Qt.AlignRight
    }
}
