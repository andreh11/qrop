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

#ifndef HARVESTMODEL_H
#define HARVESTMODEL_H

#include <QObject>
#include <QDate>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT HarvestModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int week READ week WRITE setWeek NOTIFY weekChanged)
    Q_PROPERTY(int year READ year WRITE setYear NOTIFY yearChanged)

public:
    HarvestModel(QObject *parent = nullptr, const QString &tableName = "harvest_view");

    int week() const;
    void setWeek(int week);

    int year() const;
    void setYear(int year);

signals:
    void weekChanged();
    void yearChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_week { 0 };
    QDate m_mondayDate;
    QDate m_sundayDate;

    void updateWeekDates();
};

#endif // HARVESTMODEL_H
