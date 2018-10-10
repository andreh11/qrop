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

#ifndef SQLPLANTINGMODEL_H
#define SQLPLANTINGMODEL_H

#include <QSortFilterProxyModel>
#include <QVariantMap>

#include "core_global.h"

class SqlTableModel;

class CORESHARED_EXPORT PlantingModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterFixedString NOTIFY filterStringChanged)
    Q_PROPERTY(int year READ filterYear() WRITE setFilterYear NOTIFY filterYearChanged)
    Q_PROPERTY(int season READ filterSeason() WRITE setFilterSeason NOTIFY filterSeasonChanged)
    Q_PROPERTY(QString sortColumn READ sortColumn WRITE setSortColumn NOTIFY sortColumnChanged)
    Q_PROPERTY(QString sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

public:
    PlantingModel(QObject *parent = nullptr);

    QString filterString() const;
    int filterYear() const;
    int filterSeason() const;
    QString sortColumn() const;
    QString sortOrder() const;

    void setFilterYear(int year);
    void setFilterSeason(int season);
    void setSortColumn(const QString &columnName);
    void setSortOrder(const QString &order);
    Q_INVOKABLE void refresh() const;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

signals:
    void filterStringChanged();
    void filterYearChanged();
    void filterSeasonChanged();
    void sortColumnChanged();
    void sortOrderChanged();

private:
    const QString plantingTableName = "planting_view";
    SqlTableModel *m_model;
    QString m_string;
    int m_year;
    int m_season;
    QString m_sortColumn;
    QString m_sortOrder;

    bool isDateInRange(const QDate &date) const;
    QVariant rowValue(int row, const QModelIndex &parent, const QString &field) const;
    QDate fieldDate(int row, const QModelIndex &parent, const QString &field) const;
    QVector<QDate> seasonDates() const;
};

#endif // SQLPLANTINGMODEL_H
