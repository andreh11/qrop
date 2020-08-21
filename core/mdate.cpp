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

#include <cmath>

#include <QDebug>
#include <QRegExp>
#include <QSettings>

#include "mdate.h"

MDate::MDate(QObject *parent)
    : QObject(parent)
{
}

QVariantList MDate::monthsOrder(int season)
{
    if (season < 0 || season > 3)
        return {};

    const QList<QVariantList> order({ { 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5 },
                                      { 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8 },
                                      { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 },
                                      { 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2 } });
    return order[season];
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

std::pair<QDate, QDate> MDate::weekDates(int week, int year)
{
    QDate monday = mondayOfWeek(week, year);
    return { monday, monday.addDays(6) };
}

int MDate::currentWeek()
{
    return QDate::currentDate().weekNumber();
}

int MDate::currentMonth()
{
    return QDate::currentDate().month();
}

int MDate::currentYear()
{
    int year = 0;
    QDate::currentDate().weekNumber(&year);
    return year;
}

/**
 * Format \a date according to preferred format. If \a showIndicator if
 * false, the year indicators < and > will never be shown.
 */
QString MDate::formatDate(const QDate &date, int currentYear, const QString &type, bool showIndicator)
{
    QSettings settings;
    QString dateType = settings.value("dateType", "week").toString();

    if (!type.isEmpty())
        dateType = type;

    int year = 0;
    int week = date.weekNumber(&year);
    if (dateType == QLatin1String("week")) {
        if (year == currentYear || !showIndicator)
            return QString::number(week);
        return QString("%1%2").arg(year < currentYear ? "<" : ">").arg(week);
    }
    if (year == currentYear)
        return date.toString("dd/MM");
    return date.toString("dd/MM/yyyy");
}

/**
 * @brief MDate::longYear
 * @param year
 * @return true if \a year has 53 ISO weeks
 */
bool MDate::longYear(int year)
{
    QDate lastDay(year, 12, 31);
    return lastDay.weekNumber() == 53;
}

QDate MDate::dateFromWeekString(const QString &s, int targetYear)
{
    int currentYear = 0;
    if (targetYear == 0)
        QDate::currentDate().weekNumber(&currentYear);
    else
        currentYear = targetYear;

    QRegExp regexp("([><]{0,1})([1-9]|[0-4]\\d|5[0-3])");
    if (!regexp.exactMatch(s))
        return {};

    regexp.indexIn(s);
    QStringList list = regexp.capturedTexts();

    const QString prefix = list[1];
    int week = list[2].toInt();
    int year;
    if (prefix == QLatin1String("<"))
        year = currentYear - 1;
    else if (prefix == QLatin1String(">"))
        year = currentYear + 1;
    else
        year = currentYear;

    return mondayOfWeek(week, year);
}

QDate MDate::dateFromDateString(const QString &s, int targetYear)
{
    QRegExp regexp(R"((0{,1}[1-9]|[12]\d|3[01])[/-. ](0{,1}[1-9]|1[012])([/-. ](20\d\d)){,1})");
    if (!regexp.exactMatch(s))
        return {};

    regexp.indexIn(s);
    QStringList list = regexp.capturedTexts();
    qDebug() << list;
    int day = list[1].toInt();
    int month = list[2].toInt();
    int year;
    if (list[4].isEmpty()) {
        if (targetYear == 0)
            year = QDate::currentDate().year();
        else
            year = targetYear;
    } else {
        year = list[4].toInt();
    }

    QDate date(year, month, day);
    if (!date.isValid())
        return {};

    return date;
}

QString MDate::stringFromTime(const QTime &time)
{
    return time.toString("hh:mm");
}

QTime MDate::divided(const QTime &time, int d)
{
    qreal hi;
    qreal mi;
    qreal msi;

    qreal hf = std::modf(time.hour() / d, &hi);
    qreal mf = std::modf(time.minute() / d, &mi);
    std::modf(time.msec() / d, &msi);

    return { static_cast<int>(hi), static_cast<int>((hf * 60) + mi), static_cast<int>((mf * 60) + msi) };
}

int MDate::season(const QDate &date)
{
    int month = date.month();

    if (3 <= month && month <= 5)
        return Season::Spring;
    if (6 <= month && month <= 8)
        return Season::Summer;
    if (9 <= month && month <= 11)
        return Season::Fall;
    return Season::Winter;
}

QString MDate::seasonName(int season)
{
    if (season == 0)
        return tr("Winter");
    else if (season == 1)
        return tr("Spring");
    else if (season == 2)
        return tr("Summer");
    else if (season == 3)
        return tr("Fall");
    return {};
}

std::pair<QDate, QDate> MDate::seasonDates(int season, int year)
{
    switch (season) {
    case Season::Spring:
        return { QDate(year - 1, 10, 1), QDate(year, 9, 30) };
    case Season::Fall:
        return { QDate(year, 4, 1), QDate(year + 1, 3, 31) };
    case Season::Winter:
        return { QDate(year - 1, 7, 1), QDate(year, 6, 30) };
    default: // Summer or invalid season
        return { QDate(year, 1, 1), QDate(year, 12, 31) };
    }
}

QVariantList MDate::seasonMondayDates(int season, int year)
{
    QDate beg;
    QDate end;
    std::tie(beg, end) = seasonDates(season, year);
    QVariantList list;

    while (beg <= end) {
        int w;
        int y;
        w = beg.weekNumber(&y);
        list.push_back(mondayOfWeek(w, y));
        beg = beg.addDays(7);
    }

    return list;
}

QDate MDate::seasonBeginning(int season, int year)
{
    return seasonDates(season, year).first;
}

QDate MDate::seasonEnd(int season, int year)
{
    return seasonDates(season, year).second;
}

int MDate::seasonYear(const QDate &date)
{
    if (date.month() < 12)
        return date.year();
    return date.year() + 1;
}

QString MDate::dayName(const QDate &date)
{
    if (date == QDate::currentDate())
        return tr("today");
    return MDate::dateToString(date, "dddd");
}

QString MDate::shortDayName(const QDate &date)
{
    if (date == QDate::currentDate())
        return tr("today", "abbreviation");
    return MDate::dateToString(date, "ddd");
}

QString MDate::dateToString(const QDate &date, const QString &format)
{
    QSettings settings;
    auto preferredLanguage = settings.value("preferredLanguage").toString();

    if (preferredLanguage == "system")
        return QLocale().toString(date, format);
    else
        return QLocale(preferredLanguage).toString(date, format);
}

QString MDate::monthName(int month)
{
    if (month < 1 || month > 12)
        return {};
    return MDate::dateToString(QDate(2018, month, 1), "MMMM");
}

QString MDate::shortMonthName(int month)
{
    if (month < 1 || month > 12)
        return {};
    return MDate::dateToString(QDate(2018, month, 1), "MMM");
}
