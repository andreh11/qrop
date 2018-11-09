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

MDate::MDate(QObject *parent) : QObject(parent)
{
}

QDate MDate::firstMondayOfYear(const int year)
{
    if (year < 1)
        return QDate();

    QDate date(year, 1, 1);
    int day = date.dayOfWeek();
    if (day <= Qt::Thursday)
        date = date.addDays(-day + 1);
    else
        date = date.addDays(7 - day + 1);
    return date;
}

QDate MDate::mondayOfWeek(const int week, const int year)
{
    QDate first = firstMondayOfYear(year);
    if (!first.isValid())
        return QDate();

    return first.addDays((week - 1) * 7);
}

// Format date according to preferred format.
QString MDate::formatDate(const QDate &date, const int currentYear, const QString &type)
{
    QSettings settings;
    QString dateType = settings.value("dateType", "week").toString();

    if (!type.isEmpty())
        dateType = type;

    int year;
    const int week = date.weekNumber(&year);
    if (dateType == "week") {
        if (year == currentYear)
            return QString::number(week);
        else
            return QString("%1%2").arg(year < currentYear ? "<" : ">").arg(week);
    } else {
        if (year == currentYear)
            return date.toString("dd/MM");
        else
            return date.toString("dd/MM/yyyy");
    }
}

QDate MDate::dateFromWeekString(const QString &s)
{
    const int currentYear = QDate::currentDate().year();
    QRegExp regexp("([><]{0,1})([1-9]|[0-4]\\d|5[0-3])");
    regexp.indexIn(s);
    QStringList list = regexp.capturedTexts();

    const QString prefix = list[1];
    const int week = list[2].toInt();
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
       return QDate();

    return date;
}
