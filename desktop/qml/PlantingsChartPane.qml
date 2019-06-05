/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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
import QtCharts 2.2

import io.qrop.components 1.0

ChartView {
    id: chart

    property int year: 0
    property int season: 0
    property int oldSeason: 0

    function computeField() {
        var bedLength = Location.totalBedLength(false);
        var fieldList = Planting.totalLengthByWeek(season, year, false)
        var dateList = MDate.seasonMondayDates(season, year);
        for (var i = 0; i < fieldList.length; i++) {
            fieldChart.append(dateList[i].getTime(), fieldList[i]/bedLength * 100);
        }
    }

    function computeGreenhouse() {
        var bedLength = Location.totalBedLength(true);
        var fieldList = Planting.totalLengthByWeek(season, year, true)
        var dateList = MDate.seasonMondayDates(season, year);
        for (var i = 0; i < fieldList.length; i++) {
            greenhouseChart.append(dateList[i].getTime(), fieldList[i]/bedLength * 100);
        }
    }

    function refresh() {
        if (!visible)
            return;
        fieldChart.clear();
        greenhouseChart.clear();
        computeField();
        computeGreenhouse();
    }

    antialiasing: true
    localizeNumbers: true

    onYearChanged: refresh();
    onSeasonChanged: refresh();
    onVisibleChanged: refresh();
    title: qsTr("Estimated field and greenhouse space occupied this year (in % of total bed length)")

    CategoryAxis {
        id: yValuesAxis
        min: 0
        max: 125
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
        CategoryRange {
            label: "125 %"
            endValue: 125
        }
    }

    DateTimeAxis {
        id: xValuesAxis
        format: "MMM"
        min: MDate.seasonBeginning(season,year)
        max: MDate.seasonEnd(season, year)
        tickCount: 12
        titleVisible: false
    }

    LineSeries {
        id: fieldChart
        name: qsTr("Field")
        axisY: yValuesAxis
        axisX: xValuesAxis
    }

    LineSeries {
        id: greenhouseChart
        name: qsTr("Greenhouse")
        axisY: yValuesAxis
        axisX: xValuesAxis
    }
}
