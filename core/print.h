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

#ifndef PRINT_H
#define PRINT_H

#include <QObject>
#include <QMap>
#include "core_global.h"

class CORESHARED_EXPORT Print : public QObject
{
    Q_OBJECT

public:
    explicit Print(QObject *parent = nullptr);

    Q_INVOKABLE void printCropPlan(int year, int month, int week, const QUrl &path,
                                   const QString &type = "entire");
    Q_INVOKABLE void printCalendar(int year, int month, int week, const QUrl &path,
                                   bool showOverdue = false);

private:
    typedef struct {
        QString plantingTypeClause;
        QString monthClause;
        QString orderClause;
        QString title;
        QString tableHeader;
        QString tableRow;
    } TableInfo;

    QMap<QString, TableInfo> cropPlanMap;
    QString cropPlanQueryString;
    QString cropPlanHtml(int year, int month, int week, const QString &type) const;

    TableInfo calendarInfo;
    QString calendarQueryString;
    QString calendarHtml(int year, int week, bool showOverdue) const;

    void exportPdf(const QString &html, const QUrl &path);
};

#endif // PRINT_H
