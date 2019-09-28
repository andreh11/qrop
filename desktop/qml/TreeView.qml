import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import io.qrop.components 1.0

ScrollView {
    id: root

    property var model
    property Component delegate
    property alias currentIndex: listView.currentIndex

    property var __model: TreeModelAdaptor {
        id: modelAdaptor
        model: root.model
    }

    clip: true

    ListView {
        id: listView
        spacing: 0
        highlightFollowsCurrentItem: true
        boundsBehavior: Flickable.StopAtBounds

        anchors.fill: parent
        cacheBuffer: 1000
        model: root.__model

        delegate: control.delegate
    }
}
