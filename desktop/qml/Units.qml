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

pragma Singleton
import QtQuick 2.0
import Qt.labs.settings 1.0
import QtQuick.Controls 2.4

QtObject {
    // font sizes - defaults from Google Material Design Guide
    readonly property int fontSizeDisplay4: 112
    readonly property int fontSizeDisplay3: 56
    readonly property int fontSizeDisplay2: 45
    readonly property int fontSizeDisplay1: 34
    readonly property int fontSizeHeadline: 24
    readonly property int fontSizeTitle: 20
    readonly property int fontSizeSubheading: 16
    readonly property int fontSizeBodyAndButton: 14 // default
    readonly property int fontSizeCaption: 12

    readonly property int smallSpacing: 8
    readonly property int formSpacing: 16
    readonly property int mediumSpacing: 20
    readonly property int largeSpacing: 24

    readonly property int shortDuration: 100
    readonly property int mediumDuration: 200
    readonly property int longDuration: 400

    readonly property int buttonHeight: 36
    readonly property int chipHeight: 32
    readonly property int fieldHeight: 32

    readonly property int rowHeight: 40 // Height of rows in tables.
    readonly property int monthWidth: 60 // Width of a month in a timeline.
    readonly property int timegraphWidth: monthWidth * 12
    readonly property int toolBarHeight: 48

    function coordinate(day) {
        if (day < 0)
            return 0;
        else if (day > 365)
            return timegraphWidth;
        else
            return (day / 365.0) * timegraphWidth;
    }

    function widthBetween(pos, seasonBegin, date) {
        var width = position(seasonBegin, date) - pos;
        if (width > 0)
            return width;
        else
            return 0;
    }

    function daysDelta(beg, end) {
        var msPerDay = 1000 * 60 * 60 * 24;
        return (end - beg) / msPerDay;
    }

    function position(seasonBegin, date) {
        return coordinate(daysDelta(seasonBegin, date))
    }

    function bedLength(length) {
        if (settings.useStandardBedLength) {
            return length/settings.standardBedLength
        } else {
            return length
        }
    }

    // Set item to value only if it has not been manually modified by
    // the user. To do this, we use the manuallyModified boolean value.
    function setFieldValue(item, value) {
        if (!value || item.manuallyModified)
            return;

        if (item instanceof MyTextField)
            item.text = value;
        else if (item instanceof CheckBox || item instanceof ChoiceChip)
            item.checked = value;
        else if (item instanceof MyComboBox)
            item.setRowId(value);
        else if (item instanceof DatePicker)
            item.calendarDate = Date.fromLocaleString(Qt.locale(), value, "yyyy-MM-dd")

    }

    //! Return the elements of \a componentList which have been modified.
    function editedValues(componentList) {
        var map = ({});

        for (var i = 0; i < componentList.length; i++) {
            var widget = componentList[i][0]
            var name = componentList[i][1]
            var value = componentList[i][2]

            if (widget.manuallyModified) {
                map[name] = value;
            }
        }
        return map;
    }

    function toPrecision(x, decimals) {
        return Math.round(x * (10^decimals)) / (10^decimals);
    }
}
