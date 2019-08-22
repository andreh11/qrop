import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Qt.labs.calendar 1.0
import QtCharts 2.3

import io.qrop.components 1.0

ChartView {
    id: control

    property int currentIndex: -1
    property string currentLabel
    property double currentLength: -1
    
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


    Rectangle {
        visible: currentIndex > 0
        color: Qt.rgba(0, 0, 0, 0.87)
        radius: 4
        width: childrenRect.width + 12
        height: childrenRect.height + 12

        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: Units.smallSpacing
        }

        Label {
            anchors.centerIn: parent
            text: currentLabel + " " + currentLength
            color: "#ffffffde"
            font { family: "Roboto Regular"; pixelSize: Units.fontSizeBodyAndButton }
        }
    }

    HorizontalBarSeries {
        id: barSeries
        onHovered: {
            if (status) {
                currentIndex = index
                currentLabel = barCategories.categories[index]
                currentLength = barset.values[index]
            } else {
                currentIndex = -1
            }
        }
        
        axisX: ValueAxis {
            id: xBarCategory
            min: 0
            labelsFont: Qt.font({ family: "Roboto Condensed", pixelSize: Units.fontSizeBodyAndButton} )
            tickCount: 10
        }
        
        axisY: BarCategoryAxis {
            id: barCategories
            labelsFont: Qt.font({ family: "Roboto Condensed", pixelSize: Units.fontSizeBodyAndButton} )
        }
    }
}
