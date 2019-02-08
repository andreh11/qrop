import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import io.qrop.components 1.0

MyToolButton {
    id: completeButton

    property bool done
    property bool due
    property bool overdue

    checked: done
    //                            flat: true
    checkable: true
    Text {
        anchors.fill: parent
        text: overdue ? "\ue002" : "\ue86c"
        font.family: "Material Icons"
        font.pixelSize: 30
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: parent.checked ? Material.color(Material.Green)
                              : overdue
                                ? Material.color(Material.Red)
                                : Material.color(Material.Grey,
                                                 Material.Shade300)
    }
}
