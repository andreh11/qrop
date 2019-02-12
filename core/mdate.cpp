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

#include <QDebug>
#include <QRegExp>
#include <QSettings>

#include "mdate.h"

MDate::MDate(QObject *parent)
    : QObject(parent)
{
}

int MDate::isoWeek(const QDate &date)
{
    return date.weekNumber();
}

int MDate::isoYear(const QDate &date)
{
    int year = 0;
    date.weekNumber(&year);
    return year;
}

QDate MDate::firstMondayOfYear(int year)
{
    if (year < 1)
        return {};

    QDate date(year, 1, 1);
    int day = date.dayOfWeek();
    if (day <= Qt::Thursday)
        date = date.addDays(-day + 1);
    else
        date = date.addDays(7 - day + 1);
    return date;
}

QDate MDate::mondayOfWeek(int week, int year)
{
    QDate first = firstMondayOfYear(year);
    if (!first.isValid())
        return {};

    return first.addDays((week - 1) * 7);
}

QList<QDate> MDate::weekDates(int week, int year)
{
    QDate monday = mondayOfWeek(week, year);
    return { monday, monday.addDays(6) };
}

int MDate::currentWeek()
{
    return QDate::currentDate().weekNumber();
}

int MDate::currentYear()
{
    int year = 0;
    QDate::currentDate().weekNumber(&year);
    return year;
}

/*! Format date according to preferred format. If \a showIndicator if
 * false, the year indicators < and > will never be shown. */
QString MDate::formatDate(const QDate &date, int currentYear, const QString &type, bool showIndicator)
{
    QSettings settings;
    QString dateType = settings.value("dateType", "week").toString();

    if (!type.isEmpty())
        dateType = type;

    int year;
    int week = date.weekNumber(&year);
    if (dateType == "week") {
        if (year == currentYear || !showIndicator)
            return QString::number(week);
        return QString("%1%2").arg(year < currentYear ? "<" : ">").arg(week);
    } else {
        if (year == currentYear)
            return date.toString("dd/MM");
        return date.toString("dd/MM/yyyy");
    }
}

QDate MDate::dateFromWeekString(const QString &s)
{
    int currentYear = 0;
    QDate::currentDate().weekNumber(&currentYear);

    QRegExp regexp("([><]{0,1})([1-9]|[0-4]\\d|5[0-3])");
    regexp.indexIn(s);
    QStringList list = regexp.capturedTexts();

    const QString prefix = list[1];
    int week = list[2].toInt();
    int year;
    if (prefix == "<")
        year = currentYear - 1;
    else if (prefix == ">")
        year = currentYear + 1;
    else
        year = currentYear;

    return mondayOfWeek(week, year);
}

QDate MDate::dateFromDateString(const QString &s)
{
    QRegExp regexp("(0{,1}[1-9]|[12]\\d|3[01])[/-. ](0{,1}[1-9]|1[012])([/-. ](20\\d\\d)){,1}");
    regexp.indexIn(s);
    QStringList list = regexp.capturedTexts();
    int day = list[1].toInt();
    int month = list[2].toInt();
    int year;
    if (list[4].isEmpty())
        year = QDate::currentDate().year();
    else
        year = list[4].toInt();

    QDate date(year, month, day);
    if (!date.isValid())
        return {};

    return date;
}

int MDate::season(const QDate &date)
{
    int month = date.month();

    if (3 <= month && month <= 5)
        return SPRING;
    else if (6 <= month && month <= 8)
        return SUMMER;
    else if (9 <= month && month <= 11)
        return FALL;
    else
        return WINTER;
}

QPair<QDate, QDate> MDate::seasonDates(int season, int year)
{
    switch (season) {
    case SPRING:
        return { QDate(year - 1, 10, 1), QDate(year, 9, 30) };
    case FALL:
        return { QDate(year, 4, 1), QDate(year + 1, 3, 31) };
    case WINTER:
        return { QDate(year - 1, 7, 1), QDate(year, 6, 30) };
    default: // Summer or invalid season
        return { QDate(year, 1, 1), QDate(year, 12, 31) };
    }
}

QDate MDate::seasonBeginning(int season, int year)
{
    return seasonDates(season, year).first;
}

int MDate::seasonYear(const QDate &date)
{
    if (date.month() < 12)
        return date.year();
    return date.year() + 1;
}

QString MDate::dayName(const QDate &date)
{
    return date.toString("dddd");
}
