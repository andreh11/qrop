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
    Q_PROPERTY(bool showOnlyField READ showOnlyField WRITE setShowOnlyField NOTIFY showOnlyFieldChanged)
    Q_PROPERTY(bool showOnlyHarvested READ showOnlyHarvested WRITE setShowOnlyHarvested NOTIFY showOnlyHarvestedChanged)
    Q_PROPERTY(bool showFinished READ showFinished WRITE setShowFinished NOTIFY showFinishedChanged)
    Q_PROPERTY(int cropId READ cropId WRITE setCropId NOTIFY cropIdChanged)
    Q_PROPERTY(int keywordId READ keywordId WRITE setKeywordId NOTIFY keywordIdChanged)
    Q_PROPERTY(int revenue READ revenue NOTIFY revenueChanged)
    Q_PROPERTY(int totalBedLength READ totalBedLength NOTIFY totalBedLengthChanged)

public:
    enum { InfoMap = Qt::UserRole + 300 };
    PlantingModel(QObject *parent = nullptr, const QString &tableName = "planting_view");
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    QVariant data(const QModelIndex &proxyIndex, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int week() const;
    void setWeek(int week);

    bool showActivePlantings() const;
    void setShowActivePlantings(bool show);

    bool showOnlyUnassigned() const;
    void setShowOnlyUnassigned(bool show);

    bool showOnlyGreenhouse() const;
    void setShowOnlyGreenhouse(bool show);

    bool showOnlyField() const;
    void setShowOnlyField(bool show);

    bool showOnlyHarvested() const;
    void setShowOnlyHarvested(bool show);

    bool showFinished() const;
    void setShowFinished(bool show);

    int cropId() const;
    void setCropId(int cropId);

    int keywordId() const;
    void setKeywordId(int keywordId);

    int revenue() const;
    qreal totalBedLength() const;

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_week { -1 };
    bool m_showActivePlantings { false };
    bool m_showOnlyUnassigned { false };
    bool m_showOnlyGreenhouse { false };
    bool m_showOnlyField { false };
    bool m_showOnlyHarvested { false };
    bool m_showFinished { true };
    int m_cropId { -1 };
    int m_keywordId { -1 };
    Location *location;
    Planting *planting;

signals:
    void weekChanged();
    void showActivePlantingsChanged();
    void showOnlyUnassignedChanged();
    void showOnlyGreenhouseChanged();
    void showOnlyFieldChanged();
    void showOnlyHarvestedChanged();
    void showFinishedChanged();
    void cropIdChanged();
    void keywordIdChanged();
    void revenueChanged();
    void totalBedLengthChanged();
};

#endif // PLANTINGMODEL_H
