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

#include <QDate>
#include <QDebug>

#include "mdate.h"
#include "helpers.h"

Helpers::Helpers(QObject *parent)
    : QObject(parent)
{
}

qreal Helpers::coordinate(qint64 dayNumber)
{
    if (dayNumber < 0)
        return 0;
    else if (dayNumber > 365)
        return mGraphWidth;
    return (dayNumber / 365.0) * mGraphWidth;
}

qreal Helpers::position(const QDate &seasonBegin, const QDate &date)
{
    return coordinate(MDate::daysTo(seasonBegin, date));
}

qreal Helpers::widthBetween(qreal pos, const QDate &seasonBegin, const QDate &date)
{
    qreal width = position(seasonBegin, date) - pos;
    if (width < 0)
        return 0;
    return width;
}
