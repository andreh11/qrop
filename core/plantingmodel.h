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

//#include <QSortFilterProxyModel>
#include <QVariantMap>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class SqlTableModel;
class Location;
class Planting;

class CORESHARED_EXPORT PlantingModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int week READ week WRITE setWeek NOTIFY weekChanged)
    Q_PROPERTY(bool showActivePlantings READ showActivePlantings WRITE setShowActivePlantings NOTIFY
                       showActivePlantingsChanged)
    Q_PROPERTY(bool showOnlyUnassigned READ showOnlyUnassigned WRITE setShowOnlyUnassigned NOTIFY
                       showOnlyUnassignedChanged)

public:
    PlantingModel(QObject *parent = nullptr, const QString &tableName = "planting_view");

    int week() const;
    void setWeek(int week);

    bool showActivePlantings() const;
    void setShowActivePlantings(bool show);

    bool showOnlyUnassigned() const;
    void setShowOnlyUnassigned(bool show);

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_week;
    bool m_showActivePlantings;
    bool m_showOnlyUnassigned;
    Location *location;
    Planting *planting;

signals:
    void weekChanged();
    void showActivePlantingsChanged();
    void showOnlyUnassignedChanged();
};

#endif // SQLPLANTINGMODEL_H
