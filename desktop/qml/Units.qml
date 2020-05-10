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

pragma Singleton
import QtQuick 2.0

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
    readonly property int fontSizeTable: fontSizeBodyAndButton

    readonly property var body1Font: {
        "family": "Eczar Regular",
        "size": 16,
        "capitalization": Font.Normal
    }

    readonly property var body2Font: {
        "family": "Roboto Condensed Light",
        "size": 14,
        "capitalization": Font.Normal
    }

    readonly property var captionFont: {
        "family": "Roboto Condensed Regular",
        "size": 10,
        "capitalization": Font.AllUppercase
    }

    readonly property int smallSpacing: 8
    readonly property int formSpacing: 16
    readonly property int mediumSpacing: 20
    readonly property int largeSpacing: 24

    readonly property int tableHeaderHeight: 56
    readonly property int tableRowHeight: 52

    readonly property int desktopSideSheetWidth: 320
    readonly property color closeButtonColor: Qt.rgba(0.459, 0.459, 0.459)

    readonly property int shortDuration: 100
    readonly property int mediumDuration: 200
    readonly property int longDuration: 400

    readonly property int buttonHeight: 36
    readonly property int chipHeight: 32
    readonly property int chipPadding: 12
    readonly property int fieldHeight: 32

    readonly property int rowHeight: 40 // Height of rows in tables.
    readonly property int monthWidth: 60 // Width of a month in a timeline.
    readonly property int timegraphWidth: monthWidth * 12
    readonly property int toolBarHeight: 48
    readonly property int listSingleLineHeight: 48

    readonly property color colorHighEmphasis: Qt.rgba(0, 0, 0, 0.87)
    readonly property color colorMediumEmphasis: Qt.rgba(0, 0, 0, 0.6)
    readonly property color colorDisabledEmphasis: Qt.rgba(0, 0, 0, 0.38)
    readonly property color colorError: Qt.rgba(176/255., 0, 32/255., 1)
    readonly property color pageColor: Material.color(Material.Grey, Material.Shade100)

    readonly property int dialogHeaderHeight: 72

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
        if (width < 0)
            return 0;
        return width;
    }

    function position(seasonBegin, date) {
        return coordinate(MDate.daysTo(seasonBegin, date))
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
