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

#ifndef TASKMODEL_H
#define TASKMODEL_H

#include <QDate>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class Location;
class Planting;
class Task;

class CORESHARED_EXPORT TaskModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setFilterDate NOTIFY dateChanged)
    Q_PROPERTY(int week READ week WRITE setWeek NOTIFY weekChanged)
    Q_PROPERTY(int year READ year WRITE setYear NOTIFY yearChanged)
    Q_PROPERTY(bool showDone READ showDone WRITE setShowDone NOTIFY showDoneChanged)
    Q_PROPERTY(bool showDue READ showDue WRITE setShowDue NOTIFY showDueChanged)
    Q_PROPERTY(bool showOverdue READ showOverdue WRITE setShowOverdue NOTIFY showOverdueChanged)
    Q_PROPERTY(int plantingId READ plantingId WRITE setPlantingId NOTIFY plantingIdChanged)

public:
    TaskModel(QObject *parent = nullptr, const QString &tableName = "task_view");
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    QVariant data(const QModelIndex &idx, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void setSortColumn(const QString &columnName) override;
    void setSortOrder(const QString &order) override;

    QDate date() const;
    void setFilterDate(const QDate &date);

    int week() const;
    void setWeek(int week);

    int year() const;
    void setYear(int year);

    bool showDone() const;
    void setShowDone(bool showDone);

    bool showDue() const;
    void setShowDue(bool showDue);

    bool showOverdue() const;
    void setShowOverdue(bool showOverdue);

    int plantingId() const;
    void setPlantingId(int id);

signals:
    void dateChanged();
    void weekChanged();
    void yearChanged();
    void showDoneChanged();
    void showDueChanged();
    void showOverdueChanged();
    void plantingIdChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    QDate m_filterDate;
    int m_week { 0 };
    QDate m_mondayDate;
    QDate m_sundayDate;
    bool m_showDone { false };
    bool m_showDue { false };
    bool m_showOverdue { false };
    int m_plantingId { -1 };

    Location *m_location;
    Planting *m_planting;
    Task *m_task;

    void updateWeekDates();
    bool showPlantingTasks() const;
    bool done(int row, const QModelIndex &parent) const;
    bool due(int row, const QModelIndex &parent) const;
    bool overdue(int row, const QModelIndex &parent) const;
    bool isAssignedToPlanting(int sourceRow, const QModelIndex &sourceParent) const;
    bool isInSeason(int sourceRow, const QModelIndex &sourceParent) const;
};

#endif // TASKMODEL_H
