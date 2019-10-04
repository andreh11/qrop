import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

import io.qrop.components 1.0

Item {
    id: control

    property int taskId: -1
    property string taskColor: taskMap["color"]
    property int duration: taskMap["duration"]
    property date seasonBegin
    property int season
    property int year
    property var taskMap: Task.drawInfoMap(taskId, season, year)
    property string description: taskId > 0 ? taskMap["description"] : ""
    property alias hovered: mouseArea.containsMouse

    x: taskMap["graphStart"]
    height: Units.rowHeight
    implicitHeight: Units.rowHeight
    width: taskBar.width + (label.wideEnough ? 0 : label.implicitWidth)

    ToolTip.visible: mouseArea.containsMouse
    ToolTip.delay: 200
    ToolTip.text: taskMap["toolTip"]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        id: taskBar
        width: taskMap["width"]
        radius: 3
        visible: duration > 0 && width > 0
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
        color: taskColor
        opacity: 0.8
    }

    Label {
        id: label
        property bool wideEnough: taskBar.width > 20
        anchors {
            left: taskBar.left
            verticalCenter: parent.verticalCenter
            leftMargin: wideEnough ? 4 : -2
        }
        text: description
        visible: taskBar.width
        rotation: wideEnough ? 0 : -90
        font.family: "Roboto Condensed"
        font.pixelSize: Units.fontSizeBodyAndButton
        antialiasing: true
        color: Material.color(Material.Grey, taskBar.width < 10 ? Material.Shade600 : Material.Shade100)
    }
}
