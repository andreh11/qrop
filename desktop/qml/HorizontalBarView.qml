import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0

import QtCharts 2.2

import io.qrop.components 1.0

ChartView {
    id: control
    
    function compute(names, lengths) {
        barCategories.clear();
        barSeries.clear();
        
        barCategories.categories = names.length ? names : ["."];
        barSeries.append(qsTr(""), lengths)
        xBarCategory.max = lengths.length ? Math.max(...lengths) : 0.1
    }
    
    legend.alignment: Qt.AlignBottom
    antialiasing: true
    legend.visible: false
    
    HorizontalBarSeries {
        id: barSeries
        
        axisX: ValueAxis {
            id: xBarCategory
            min: 0
        }
        
        axisY: BarCategoryAxis {
            id: barCategories
        }
    }
}
