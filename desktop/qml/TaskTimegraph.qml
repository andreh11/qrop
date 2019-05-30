import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

import io.qrop.components 1.0

Item {
    id: control

    property int taskId: -1
    property string type: Task.type(taskId)
    property string taskColor: Task.color(taskId)
    property int duration: Task.duration(taskId)
    property date assignedDate: Task.assignedDate(taskId)
    property date taskEndDate: MDate.addDays(assignedDate, duration)
    property date seasonBegin

    height: Units.rowHeight
    implicitHeight: Units.rowHeight
    width: taskBar.x + taskBar.width

    function acronymize(string) {
        var stringList = string.split(" ");
        if (stringList.length > 1) {
            var s = ""
            for (var i = 0; i < stringList.length; i++)
                s += stringList[i][0].toString().toUpperCase();
            return s;
        } else {
            return stringList[0][0] + stringList[0][1].toString().toUpperCase();
        }
    }

    Rectangle {
        id: taskBar
        x: Units.position(seasonBegin, assignedDate)
        width: Units.widthBetween(x, seasonBegin, taskEndDate)
        visible: width > 0
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
        color: taskColor

        Label {
            text: acronymize(type)
            font.family: "Roboto Condensed"
            font.pixelSize: Units.fontSizeBodyAndButton
            antialiasing: true
            color: Material.color(Material.Grey, Material.Shade100)
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
        }
    }
}
