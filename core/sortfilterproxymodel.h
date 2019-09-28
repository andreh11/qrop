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

#ifndef SORTFILTERPROXYMODEL_H
#define SORTFILTERPROXYMODEL_H

#include <QObject>
#include <QDebug>
#include <QSortFilterProxyModel>

#include "core_global.h"

class SqlTableModel;

class CORESHARED_EXPORT SortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterFixedString NOTIFY filterStringChanged)
    Q_PROPERTY(int year READ filterYear() WRITE setFilterYear NOTIFY filterYearChanged)
    Q_PROPERTY(int season READ filterSeason() WRITE setFilterSeason NOTIFY filterSeasonChanged)
    Q_PROPERTY(QString sortColumn READ sortColumn WRITE setSortColumn NOTIFY sortColumnChanged)
    Q_PROPERTY(QString sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int rowCount READ rowCount() NOTIFY countChanged)

public:
    SortFilterProxyModel(QObject *parent = nullptr, const QString &tableName = "");

    Q_INVOKABLE QList<int> idList() const;
    Q_INVOKABLE int rowId(int row) const;
    Q_INVOKABLE int idRow(int id) const;
    int roleIndex(const QString &roleName) const;
    Q_INVOKABLE void resetFilter() { invalidateFilter(); }
    Q_INVOKABLE virtual void refresh();
    Q_INVOKABLE void refreshRow(int row);

    QString filterString() const;

    int filterYear() const;
    void setFilterYear(int year);

    int filterSeason() const;
    void setFilterSeason(int season);

    QString sortColumn() const;
    virtual void setSortColumn(const QString &columnName);

    QString sortOrder() const;
    virtual void setSortOrder(const QString &order);

    void setFilterKeyStringColumn(const QString &columnName);

    std::pair<QDate, QDate> seasonDates() const;

    virtual QVariant rowValue(const QModelIndex &index, const QString &field) const;
    virtual QVariant rowValue(int row, const QModelIndex &parent, const QString &field) const;
    QVariant rowValue(int row, const QString &field) const;

signals:
    void filterStringChanged();
    void filterYearChanged();
    void filterSeasonChanged();
    void sortColumnChanged();
    void sortOrderChanged();
    void selectionChanged();
    void countChanged();

protected:
    virtual bool isDateInRange(const QDate &date) const;
    virtual QVariant sourceRowValue(int sourceRow, const QModelIndex &sourceParent,
                                    const QString &field) const;
    QDate sourceFieldDate(int row, const QModelIndex &parent, const QString &field) const;

    SqlTableModel *m_model;
    int m_year;
    int m_season { 1 }; // default: summer
    QString m_sortColumn;
    QString m_sortOrder { "ascending" };

private:
    QString m_tableName;
    QString m_string;
};

#endif // SORTFILTERPROXYMODEL_H
