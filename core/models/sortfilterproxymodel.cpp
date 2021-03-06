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

#include <QDate>
#include <QDebug>
#include <QElapsedTimer>

#include "sortfilterproxymodel.h"
#include "sqltablemodel.h"
#include "qrpdate.h"

SortFilterProxyModel::SortFilterProxyModel(QObject *parent, const QString &tableName)
    : QSortFilterProxyModel(parent)
    , m_model(new SqlTableModel(this))
    , m_year(QDate::currentDate().year())
    , m_tableName(tableName)
{
    m_model->setTable(tableName);
    m_model->select();
    setSourceModel(m_model);

    connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));

    setFilterKeyColumn(-1);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
}

QList<int> SortFilterProxyModel::idList() const
{
    QList<int> list;
    for (int row = 0; row < rowCount(); ++row) {
        QModelIndex idx = index(row, 0);
        QModelIndex sourceIndex = mapToSource(idx);
        int id = m_model->data(sourceIndex, Qt::UserRole).toInt();
        list.append(id);
    }
    return list;
}

int SortFilterProxyModel::rowId(int row) const
{
    QModelIndex sourceIndex = mapToSource(index(row, 0));
    int id = m_model->data(sourceIndex, Qt::UserRole).toInt();
    return id;
}

int SortFilterProxyModel::roleIndex(const QString &roleName) const
{
    Q_ASSERT(m_model);
    return m_model->roleIndex(roleName);
}

int SortFilterProxyModel::idRow(int id) const
{
    return idList().indexOf(id);
}

void SortFilterProxyModel::refresh()
{
    m_model->select();
    emit countChanged();
}

// TODO: not working
void SortFilterProxyModel::refreshRow(int row)
{
    Q_ASSERT(row >= 0);
    Q_ASSERT(row < rowCount());

    auto idx = mapToSource(index(row, 0));
    m_model->selectRow(idx.row());
}

void SortFilterProxyModel::dataChangedForAll()
{
    emit layoutAboutToBeChanged();
    emit layoutChanged();
    //    emit dataChanged(index(0, 0), index(rowCount() - 1, 0));
}

QString SortFilterProxyModel::filterString() const
{
    return m_string;
}

int SortFilterProxyModel::filterYear() const
{
    return m_year;
}

int SortFilterProxyModel::filterSeason() const
{
    return m_season;
}

QString SortFilterProxyModel::sortColumn() const
{
    return m_sortColumn;
}

QString SortFilterProxyModel::sortOrder() const
{
    return m_sortOrder;
}

void SortFilterProxyModel::setFilterYear(int year)
{
    if (year == m_year)
        return;

    m_year = year;
    emit filterYearChanged();
    invalidateFilter();
}

void SortFilterProxyModel::setFilterSeason(int season)
{
    if (season == m_season)
        return;

    if (0 <= season && season <= 3)
        m_season = season;
    else
        m_season = 1; // default to Spring

    emit filterSeasonChanged();
    invalidateFilter();
}

void SortFilterProxyModel::setFilterKeyStringColumn(const QString &columnName)
{
    setFilterKeyColumn(roleIndex(columnName));
}

void SortFilterProxyModel::setSortColumn(const QString &columnName)
{
    m_sortColumn = columnName;
    sort(roleIndex(m_sortColumn),
         m_sortOrder == QLatin1String("ascending") ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortColumnChanged();
}

void SortFilterProxyModel::setSortOrder(const QString &order)
{
    m_sortOrder = order;
    sort(roleIndex(m_sortColumn),
         m_sortOrder == QLatin1String("ascending") ? Qt::AscendingOrder : Qt::DescendingOrder);
    emit sortOrderChanged();
}

std::pair<QDate, QDate> SortFilterProxyModel::seasonDates() const
{
    return QrpDate::seasonDates(m_season, m_year);
}

QVariant SortFilterProxyModel::rowValue(const QModelIndex &index, const QString &field) const
{
    auto sourceIndex = mapToSource(index);
    if (!sourceIndex.isValid())
        return {};
    return m_model->data(sourceIndex, field);
}

QVariant SortFilterProxyModel::rowValue(int row, const QModelIndex &parent, const QString &field) const
{
    return rowValue(index(row, 0, parent), field);
}

QVariant SortFilterProxyModel::rowValue(int row, const QString &field) const
{
    return rowValue(row, QModelIndex(), field);
}

/**
 * @brief SortFilterProxyModel::sourceRowValue
 * @param row the row in the source model
 * @param parent the parent in the source model
 * @param field
 * @return the value of \a field for (row, parent) in the source model
 * @see SortFilterProxyModel::rowValue
 */
QVariant SortFilterProxyModel::sourceRowValue(int sourceRow, const QModelIndex &sourceParent,
                                              const QString &field) const
{
    auto index = m_model->index(sourceRow, 0, sourceParent);
    if (!index.isValid())
        return {};

    return m_model->data(index, field);
}

QDate SortFilterProxyModel::sourceFieldDate(int row, const QModelIndex &parent, const QString &field) const
{
    auto value = sourceRowValue(row, parent, field);
    if (value.isNull())
        return {};

    QString string = value.toString();
    return QDate::fromString(string, Qt::ISODate);
}

bool SortFilterProxyModel::isDateInRange(const QDate &date) const
{
    const auto dates = seasonDates();
    QDate seasonBeg = dates.first;
    QDate seasonEnd = dates.second;

    return (seasonBeg <= date) && (date < seasonEnd);
}
