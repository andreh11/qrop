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
    property int numberOfCrops

    function refresh() {
        var names = Planting.longestCropNames(year, greenhouse)
        var lengths = Planting.longestCropLengths(year, greenhouse);
        compute(names, lengths);
        numberOfCrops = names.length
    }

    title: qsTr("Crop space distribution (in bed meter)")
    onYearChanged: refresh();
    onGreenhouseChanged: refresh();
}
