import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ScrollView {
    id: control

    property var model
    property Component delegate
    property alias currentIndex: listView.currentIndex

    clip: true

    ListView {
        id: listView
        spacing: 0
        highlightFollowsCurrentItem: true
        boundsBehavior: Flickable.StopAtBounds

        anchors.fill: parent
        cacheBuffer: 1000
        model: control.model

        delegate: control.delegate
    }
}
