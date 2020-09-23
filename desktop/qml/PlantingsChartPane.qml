/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtCharts 2.3

import io.qrop.components 1.0

Item {
    id: control

    property int year: 0
    property int season: 0
    property int oldSeason: 0
    property int keywordId: -1
    property bool percentage: relativeButton.checked

    function computeField() {
        var bedLength = Location.totalBedLength(false);
        var fieldList = Planting.totalLengthByWeek(season, year, keywordId, false)
        var dateList = QrpDate.seasonMondayDates(season, year);
        var max = 0
        for (var i = 0; i < fieldList.length; i++) {
            if (percentage) {
                fieldChart.append(dateList[i].getTime(), fieldList[i]/bedLength);
            } else {
                var length = Helpers.bedLength(fieldList[i])
                if (length > max)
                    max = length
                fieldChart.append(dateList[i].getTime(), length);
            }
        }
        if (!percentage)
            yValueAxis.max = max
        else
            yValueAxis.max = 1.25
    }

    function computeGreenhouse() {
        var bedLength = Location.totalBedLength(true);
        var fieldList = Planting.totalLengthByWeek(season, year, keywordId, true)
        var dateList = QrpDate.seasonMondayDates(season, year);
        for (var i = 0; i < fieldList.length; i++) {
            if (percentage) {
                greenhouseChart.append(dateList[i].getTime(), fieldList[i]/bedLength);
            } else {
                var length = Helpers.bedLength(fieldList[i])
                greenhouseChart.append(dateList[i].getTime(), length);
            }
        }
    }

    function computeYAxis() {
        yCategoryAxis.appendAxisChildren()
    }

    function refresh() {
        if (!visible)
            return;
        fieldChart.clear();
        greenhouseChart.clear();
        computeField();
        computeGreenhouse();
        toolTip.visible = false;
    }

    function setToolTip(point) {
        var p = chart.mapToPosition(point)

        var text = percentage ? qsTr("S%1 %2%").arg().arg(Math.round(point.y * 100))
                              : qsTr("%L1").arg(Math.round(point.y * 10))
        toolTip.x = p.x - toolTip.width/2
        toolTip.y = p.y - toolTip.height - Units.smallSpacing
        toolTip.text = text
        toolTip.visible = true
    }

    onYearChanged: refresh();
    onSeasonChanged: refresh();
    onVisibleChanged: refresh();
    onKeywordIdChanged: refresh();
    onPercentageChanged: refresh();

    Row {
        id: checkButtonRow
        z: 1
        anchors {
            right: parent.right
            top: parent.top
            margins: Units.mediumSpacing
        }

        ButtonCheckBox {
            id: relativeButton
            checked: true
            text: qsTr("Relative")
            autoExclusive: true
        }

        ButtonCheckBox {
            id: absoluteButton
            text: qsTr("Absolute")
            autoExclusive: true
        }
    }

    ChartView {
        id: chart

        antialiasing: true
        localizeNumbers: true
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: keywordLayout.top
        }

        title: qsTr("Estimated field and greenhouse space occupied this year")

        ToolTip {
             id: toolTip
         }

        ValueAxis {
            id: yValueAxis
            min: 0
            visible: !percentage
            tickInterval: 5
        }

        CategoryAxis {
            id: yCategoryAxis
            visible: percentage
            min: 0
            max: 1.25
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
            CategoryRange {
                label: "0 %"
                endValue: 0
            }
            CategoryRange {
                label: "25 %"
                endValue: 0.25
            }
            CategoryRange {
                label: "50 %"
                endValue: 0.50
            }
            CategoryRange {
                label: "75 %"
                endValue: 0.75
            }
            CategoryRange {
                label: "100 %"
                endValue: 1
            }
            CategoryRange {
                label: "125 %"
                endValue: 1.25
            }
        }

        DateTimeAxis {
            id: xValuesAxis
            format: "MMM"
            min: QrpDate.seasonBeginning(season,year)
            max: QrpDate.seasonEnd(season, year)
            tickCount: 12
            titleVisible: false
        }

        LineSeries {
            id: fieldChart
            name: qsTr("Field")
            axisX: xValuesAxis
            axisY: percentage ? yCategoryAxis : yValueAxis
            pointsVisible: true
            onClicked: setToolTip(point)
        }

        LineSeries {
            id: greenhouseChart
            name: qsTr("Greenhouse")
            axisX: xValuesAxis
            axisY: percentage ? yCategoryAxis : yValueAxis
            pointsVisible: true
            onClicked: setToolTip(point)
        }
    }

    ButtonGroup {
        id: buttonGroup
    }

    RowLayout {
        id: keywordLayout
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Units.mediumSpacing
        }

        ListView {
            id: keywordListView
            orientation: Qt.Horizontal
            height: Units.rowHeight
            spacing: Units.smallSpacing
            model: KeywordModel {
                id: keywordModel
            }

            Layout.fillWidth: true
            delegate: ChoiceChip {
                text: {
                    if (checked) {
                        "%1 <i>%L2</i>".arg(keyword)
                        .arg(Helpers.bedLength(Keyword.totalBedLenght(keyword_id, season, year)))
                    } else {
                        keyword;
                    }
                }
                ButtonGroup.group: buttonGroup

                onClicked: {
                    if (checked)
                        control.keywordId = keyword_id
                    else
                        control.keywordId = -1
                }
            }
        }
    }
}
