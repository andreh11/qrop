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

class CORESHARED_EXPORT MDate : public QObject
{
    Q_OBJECT
public:
    explicit MDate(QObject *parent = nullptr);
    Q_INVOKABLE static QDate dateFromWeekString(const QString &s);
    Q_INVOKABLE static QDate dateFromDateString(const QString &s);
    static QDate firstMondayOfYear(int year);
    static QDate mondayOfWeek(int week, int year);
    static QList<QDate> weekDates(int week, int year);
    Q_INVOKABLE static int isoWeek(const QDate &date);
    Q_INVOKABLE static int isoYear(const QDate &date);
    Q_INVOKABLE static int currentWeek();
    Q_INVOKABLE static int currentYear();
    Q_INVOKABLE static QString formatDate(const QDate &date, int currentYear, const QString &type = "");
    Q_INVOKABLE static int season(const QDate &date);
    Q_INVOKABLE static int seasonYear(const QDate &date);
};

#endif // MDATE_H
