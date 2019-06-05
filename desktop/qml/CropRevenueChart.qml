import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import QtCharts 2.2

import io.qrop.components 1.0

HorizontalBarView {
    id: control

    property int year
    property bool greenhouse
    property var names
    property var lengths

    function refresh() {
        names = Planting.highestRevenueCropNames(year, greenhouse)
        lengths = Planting.highestRevenueCropRevenues(year, greenhouse);
        compute(names, lengths);
    }

    title: qsTr("Crop revenue distribution (in €)")
    theme: ChartView.ChartThemeQt
    onYearChanged: refresh();
    onGreenhouseChanged: refresh();
}
