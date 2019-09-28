import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    id: control
    property alias model: repeater.model
    property date seasonBegin

    Repeater {
        id: repeater
        TaskTimegraph {
            taskId: modelData
            seasonBegin: control.seasonBegin
        }
    }
}
