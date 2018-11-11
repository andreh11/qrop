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

Item {
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
    readonly property int mediumSpacing: 20
    readonly property int largeSpacing: 24

    readonly property int shortDuration: 100
    readonly property int mediumDuration: 200
    readonly property int longDuration: 400

    readonly property int buttonHeight: 36
    readonly property int chipHeight: 32

    // Height of rows in tables.
    readonly property int rowHeight: 36
    // Width of a month in a timeline.
    readonly property int monthWidth: 60
}
