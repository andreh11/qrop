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

#ifndef MDATE_H
#define MDATE_H

#include <QObject>
#include <QDate>
#include <QList>

#include "core_global.h"

namespace Season {
Q_NAMESPACE
enum Enum { Winter = 0, Spring, Summer, Fall };
Q_ENUM_NS(Enum)
}

class CORESHARED_EXPORT MDate : public QObject
{
    Q_OBJECT

public:
    explicit MDate(QObject *parent = nullptr);

    static const QList<QList<int>> monthsOrder;
    Q_INVOKABLE static QDate dateFromWeekString(const QString &s);
    Q_INVOKABLE static QDate dateFromDateString(const QString &s);
    static QDate firstMondayOfYear(int year);
    static QDate mondayOfWeek(int week, int year);
    static QList<QDate> weekDates(int week, int year);
    Q_INVOKABLE static int isoWeek(const QDate &date);
    Q_INVOKABLE static int isoYear(const QDate &date);
    Q_INVOKABLE static int currentWeek();
    Q_INVOKABLE static int currentMonth();
    Q_INVOKABLE static int currentYear();
    Q_INVOKABLE static QString formatDate(const QDate &date, int currentYear,
                                          const QString &type = "", const bool showIndicator = true);

    Q_INVOKABLE static int season(const QDate &date);
    Q_INVOKABLE static int seasonYear(const QDate &date);
    static QString seasonName(int season);
    static QPair<QDate, QDate> seasonDates(int season, int year);
    Q_INVOKABLE static QDate seasonBeginning(int season, int year);

    Q_INVOKABLE static qint64 daysTo(const QDate &from, const QDate &to) { return from.daysTo(to); }
    Q_INVOKABLE static QDate addDays(const QDate &date, qint64 days) { return date.addDays(days); }
    Q_INVOKABLE static QString dayName(const QDate &date);
    Q_INVOKABLE static QString monthName(int month);
    Q_INVOKABLE static QString shortMonthName(int month);
};

#endif // MDATE_H
