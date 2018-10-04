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
#include "sqltablemodel.h"

class CORESHARED_EXPORT PlantingModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterFixedString NOTIFY filterStringChanged)
    Q_PROPERTY(int year READ filterYear() WRITE setFilterYear NOTIFY filterYearChanged)
    Q_PROPERTY(int season READ filterSeason() WRITE setFilterSeason NOTIFY filterSeasonChanged)

public:
    PlantingModel(QObject *parent = nullptr);

    QString filterString() const;
    int filterYear() const;
    int filterSeason() const;

    Q_INVOKABLE void setFilterYear(int year);
    Q_INVOKABLE void setFilterSeason(int season);
    Q_INVOKABLE void setSortColumn(const QString &columnName, const QString &order);
    Q_INVOKABLE void refresh() const;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

signals:
    void filterStringChanged();
    void filterYearChanged();
    void filterSeasonChanged();

private:
    QString m_crop;
    QString m_string;
    QHash<QModelIndex, bool> m_selected;
    SqlTableModel *m_model;
    int m_year;
    int m_season;

    bool isDateInRange(const QDate &date) const;
    QVariant rowValue(int row, const QModelIndex &parent, const QString &field) const;
    QDate fieldDate(int row, const QModelIndex &parent, const QString &field) const;
    QVector<QDate> seasonDates() const;
};

#endif // SQLPLANTINGMODEL_H
