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

#ifndef PLANTINGMODEL_H
#define PLANTINGMODEL_H

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
    Q_PROPERTY(bool showOnlyGreenhouse READ showOnlyGreenhouse WRITE setShowOnlyGreenhouse NOTIFY
                       showOnlyGreenhouseChanged)
    Q_PROPERTY(bool showOnlyHarvested READ showOnlyHarvested WRITE setShowOnlyHarvested NOTIFY showOnlyHarvestedChanged)
    Q_PROPERTY(int cropId READ cropId WRITE setCropId NOTIFY cropIdChanged)
    Q_PROPERTY(int revenue READ revenue NOTIFY revenueChanged)

public:
    PlantingModel(QObject *parent = nullptr, const QString &tableName = "planting_view");
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

    int week() const;
    void setWeek(int week);

    bool showActivePlantings() const;
    void setShowActivePlantings(bool show);

    bool showOnlyUnassigned() const;
    void setShowOnlyUnassigned(bool show);

    bool showOnlyGreenhouse() const;
    void setShowOnlyGreenhouse(bool show);

    bool showOnlyHarvested() const;
    void setShowOnlyHarvested(bool show);

    int cropId() const;
    void setCropId(int cropId);

    int revenue() const;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_week { -1 };
    bool m_showActivePlantings { false };
    bool m_showOnlyUnassigned { false };
    bool m_showOnlyGreenhouse { false };
    bool m_showOnlyHarvested { false };
    int m_cropId { -1 };
    Location *location;
    Planting *planting;

signals:
    void weekChanged();
    void showActivePlantingsChanged();
    void showOnlyUnassignedChanged();
    void showOnlyGreenhouseChanged();
    void showOnlyHarvestedChanged();
    void cropIdChanged();
    void revenueChanged();
};

#endif // PLANTINGMODEL_H
