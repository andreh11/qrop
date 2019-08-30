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
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QElapsedTimer>

#include "location.h"
#include "planting.h"
#include "task.h"

#include "mdate.h"
#include "taskmodel.h"

TaskModel::TaskModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , mLocation(new Location(this))
    , mPlanting(new Planting(this))
    , mTask(new Task(this))
{
    setSortColumn("assigned_date");
    m_filterDate = QDate();
    setDynamicSortFilter(true);
}

void TaskModel::setSortColumn(const QString &columnName)
{
    m_sortColumn = columnName;
    QElapsedTimer timer;
    timer.start();
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    qDebug() << "sortColumn time:" << timer.elapsed() << "ms";
    sortColumnChanged();
}

void TaskModel::setSortOrder(const QString &order)
{
    m_sortOrder = order;
    QElapsedTimer timer;
    timer.start();
    sort(0, m_sortOrder == "ascending" ? Qt::AscendingOrder : Qt::DescendingOrder);
    qDebug() << "sortOrder time:" << timer.elapsed() << "ms";
    sortOrderChanged();
}

bool TaskModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    auto leftType = rowValue(left.row(), left.parent(), "task_type_id").toInt();
    auto rightType = rowValue(right.row(), right.parent(), "task_type_id").toInt();

    if (m_plantingId < 0) { // We don't care about task types when listing one planting's tasks.
        if (leftType < rightType)
            return QSortFilterProxyModel::sortOrder() == Qt::AscendingOrder;
        else if (leftType > rightType)
            return QSortFilterProxyModel::sortOrder() == Qt::DescendingOrder;
    }

    bool before = true;
    if (m_sortColumn == QStringLiteral("assigned_date")) {
        auto leftDate = fieldDate(left.row(), left.parent(), "completed_date");
        auto rightDate = fieldDate(right.row(), right.parent(), "completed_date");

        if (!leftDate.isValid())
            leftDate = fieldDate(left.row(), left.parent(), "assigned_date");
        if (!rightDate.isValid())
            rightDate = fieldDate(right.row(), right.parent(), "assigned_date");

        before = leftDate < rightDate;
    } else if (m_sortColumn == QStringLiteral("plantings")) {
        int leftId = rowValue(left.row(), left.parent(), QStringLiteral("task_id")).toInt();
        int rightId = rowValue(right.row(), right.parent(), QStringLiteral("task_id")).toInt();
        auto leftPlantingList = mTask->taskPlantings(leftId);
        auto rightPlantingList = mTask->taskPlantings(rightId);

        int leftPlantingId = leftPlantingList.isEmpty() ? -1 : leftPlantingList.first();
        int rightPlantingId = rightPlantingList.isEmpty() ? -1 : rightPlantingList.first();

        if (leftPlantingId > 0 && rightPlantingId > 0) {
            auto leftRecord = mPlanting->recordFromId(QStringLiteral("planting_view"), leftPlantingId);
            auto rightRecord =
                    mPlanting->recordFromId(QStringLiteral("planting_view"), rightPlantingId);

            QString leftCrop = leftRecord.value(QStringLiteral("crop")).toString();
            QString rightCrop = rightRecord.value(QStringLiteral("crop")).toString();

            int comp = leftCrop.compare(rightCrop);
            if (comp == -1)
                before = true;
            else if (comp == 1)
                before = false;
            else
                before = (leftRecord.value(QStringLiteral("variety"))
                          < rightRecord.value(QStringLiteral("variety")));
        }
    } else if (m_sortColumn == QStringLiteral("locations")) {
        int leftId = rowValue(left.row(), left.parent(), "task_id").toInt();
        int rightId = rowValue(right.row(), right.parent(), "task_id").toInt();
        auto leftLocationList = mTask->taskLocations(leftId);
        auto rightLocationList = mTask->taskLocations(rightId);

        if (leftLocationList.isEmpty()) { // planting task
            auto leftPlantingList = mTask->taskPlantings(leftId);
            if (!leftPlantingList.isEmpty())
                leftLocationList = mLocation->locations(leftPlantingList.first());
        }

        if (rightLocationList.isEmpty()) { // planting task
            auto rightPlantingList = mTask->taskPlantings(rightId);
            if (!rightPlantingList.isEmpty())
                rightLocationList = mLocation->locations(rightPlantingList.first());
        }

        int leftLocationId = leftLocationList.isEmpty() ? -1 : leftLocationList.first();
        int rightLocationId = rightLocationList.isEmpty() ? -1 : rightLocationList.first();

        before = mLocation->fullName(leftLocationId) < mLocation->fullName(rightLocationId);
    } else if (m_sortColumn == "descr") {
        int leftId = rowValue(left.row(), left.parent(), "task_id").toInt();
        int rightId = rowValue(right.row(), right.parent(), "task_id").toInt();
        before = mTask->description(leftId) < mTask->description(rightId);
    }

    return before;
}

QVariant TaskModel::data(const QModelIndex &idx, int role) const
{
    QModelIndex sourceIndex = mapToSource(idx);
    switch (role) {
    case Qt::UserRole + 100:
        return overdue(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 101:
        return due(sourceIndex.row(), sourceIndex.parent());
    case Qt::UserRole + 102:
        return done(sourceIndex.row(), sourceIndex.parent());
    default:
        return SortFilterProxyModel::data(idx, role);
    }
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    auto roles = SortFilterProxyModel::roleNames();
    roles.insert(Qt::UserRole + 100, "overdue");
    roles.insert(Qt::UserRole + 101, "due");
    roles.insert(Qt::UserRole + 102, "done");
    return roles;
}

QDate TaskModel::date() const
{
    return m_filterDate;
}

void TaskModel::setFilterDate(const QDate &date)
{
    if (date == m_filterDate)
        return;

    m_filterDate = date;
    emit dateChanged();
}

int TaskModel::year() const
{
    return m_year;
}

void TaskModel::setYear(int year)
{
    if (year < 0 || m_year == year)
        return;

    m_year = year;
    updateWeekDates();
    emit yearChanged();
}

int TaskModel::week() const
{
    return m_week;
}

void TaskModel::setWeek(int week)
{
    if (week < 0 || m_week == week)
        return;

    m_week = week;
    updateWeekDates();
    emit weekChanged();
}

bool TaskModel::showDone() const
{
    return m_showDone;
}

void TaskModel::setShowDone(bool showDone)
{
    if (m_showDone == showDone)
        return;

    m_showDone = showDone;
    invalidateFilter();
    showDoneChanged();
}

bool TaskModel::showDue() const
{
    return m_showDue;
}

void TaskModel::setShowDue(bool showDue)
{
    if (m_showDue == showDue)
        return;
    m_showDue = showDue;
    invalidateFilter();
    showDueChanged();
}

bool TaskModel::showOverdue() const
{
    return m_showOverdue;
}

void TaskModel::setShowOverdue(bool showOverdue)
{
    if (m_showOverdue == showOverdue)
        return;

    m_showOverdue = showOverdue;
    invalidateFilter();
    showOverdueChanged();
}

int TaskModel::plantingId() const
{
    return m_plantingId;
}

void TaskModel::setPlantingId(int id)
{
    if (m_plantingId == id)
        return;

    m_plantingId = id;
    plantingIdChanged();
    invalidateFilter();
}

void TaskModel::updateWeekDates()
{
    std::tie(m_mondayDate, m_sundayDate) = MDate::weekDates(m_week, m_year);
    // Strangely, we have to use both of these to get everything working.
    invalidateFilter();
    invalidate();
}

bool TaskModel::done(int row, const QModelIndex &parent) const
{
    QDate completedDate = fieldDate(row, parent, "completed_date");
    bool completed = completedDate.isValid();
    return completed
            && (m_plantingId > 0
                || ((m_mondayDate <= completedDate) && (completedDate <= m_sundayDate)));
}

bool TaskModel::due(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate >= QDate::currentDate();
    return !completed && m_mondayDate <= assignedDate && assignedDate <= m_sundayDate;
}

bool TaskModel::overdue(int row, const QModelIndex &parent) const
{
    QDate assignedDate = fieldDate(row, parent, "assigned_date");
    bool completed = rowValue(row, parent, "completed_date").toString() != "";
    if (m_plantingId > 0)
        return !completed && assignedDate < QDate::currentDate();
    return !completed && assignedDate < m_mondayDate && MDate::isoYear(assignedDate) == m_year;
}

bool TaskModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_plantingId > 0) {
        auto plantingString = rowValue(sourceRow, sourceParent, "plantings").toString();
        QList<int> plantingIdList;
        for (const auto &plantingId : plantingString.split(","))
            plantingIdList.push_back(plantingId.toInt());

        return plantingIdList.contains(m_plantingId)
                && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    }

    bool inRange = (m_showOverdue && overdue(sourceRow, sourceParent))
            || (m_showDue && due(sourceRow, sourceParent))
            || (m_showDone && done(sourceRow, sourceParent));
    return inRange && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
