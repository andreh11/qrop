import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.2

import io.croplan.components 1.0
import "date.js" as MDate

Pane {
    id: chartPane
    height: graphsButton.checked ? parent.height / 4 : graphsButton.height
                                   + graphsButton.anchors.topMargin
    //            Layout.fillWidth: true
    //            Layout.fillHeight: true
    padding: 0
    Material.elevation: 2
    
    Button {
        id: graphsButton
        text: qsTr("Revenue and Space graphs")
        flat: true
        checkable: true
        checked: false
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        z: 1
    }
    
    Item {
        anchors.fill: parent
        visible: graphsButton.checked
        property real othersSlice: 0
        
        ChartView {
            id: chart
            title: qsTr("Estimated field and greenhouse space occupied this year (of X bed m.)")
            anchors.fill: parent
            //        legend.alignment: Qt.AlignBottom
            antialiasing: true
            
            CategoryAxis {
                id: yValuesAxis
                min: 0
                max: 100
                labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
                CategoryRange {
                    label: "0 %"
                    endValue: 0
                }
                CategoryRange {
                    label: "25 %"
                    endValue: 25
                }
                CategoryRange {
                    label: "50 %"
                    endValue: 50
                }
                CategoryRange {
                    label: "75 %"
                    endValue: 75
                }
                CategoryRange {
                    label: "100 %"
                    endValue: 100
                }
            }
            
            CategoryAxis {
                id: xValuesAxis
                min: 0
                max: 12
                CategoryRange {
                    label: Qt.locale().monthName(0, Locale.ShortFormat)
                    endValue: 1
                }
                CategoryRange {
                    label: Qt.locale().monthName(1, Locale.ShortFormat)
                    endValue: 2
                }
                CategoryRange {
                    label: Qt.locale().monthName(2, Locale.ShortFormat)
                    endValue: 3
                }
                CategoryRange {
                    label: Qt.locale().monthName(3, Locale.ShortFormat)
                    endValue: 4
                }
                CategoryRange {
                    label: Qt.locale().monthName(4, Locale.ShortFormat)
                    endValue: 5
                }
                CategoryRange {
                    label: Qt.locale().monthName(5, Locale.ShortFormat)
                    endValue: 6
                }
                CategoryRange {
                    label: Qt.locale().monthName(6, Locale.ShortFormat)
                    endValue: 7
                }
                CategoryRange {
                    label: Qt.locale().monthName(7, Locale.ShortFormat)
                    endValue: 8
                }
                CategoryRange {
                    label: Qt.locale().monthName(8, Locale.ShortFormat)
                    endValue: 9
                }
                CategoryRange {
                    label: Qt.locale().monthName(9, Locale.ShortFormat)
                    endValue: 10
                }
                CategoryRange {
                    label: Qt.locale().monthName(10, Locale.ShortFormat)
                    endValue: 11
                }
                CategoryRange {
                    label: Qt.locale().monthName(11, Locale.ShortFormat)
                    endValue: 12
                }
            }
            
            LineSeries {
                name: qsTr("Field")
                axisY: yValuesAxis
                axisX: xValuesAxis
                
                XYPoint {
                    x: 0
                    y: 0
                }
                XYPoint {
                    x: 1.1
                    y: 2.1
                }
                XYPoint {
                    x: 1.9
                    y: 3.3
                }
                XYPoint {
                    x: 2.1
                    y: 2.1
                }
                XYPoint {
                    x: 2.9
                    y: 4.9
                }
                XYPoint {
                    x: 3.4
                    y: 3.0
                }
                XYPoint {
                    x: 4.1
                    y: 3.3
                }
            }
            
            LineSeries {
                name: qsTr("Greenhouse")
                axisY: yValuesAxis
                axisX: xValuesAxis
                
                XYPoint {
                    x: 0
                    y: 80
                }
                XYPoint {
                    x: 1
                    y: 60
                }
            }
        }
    }
}
