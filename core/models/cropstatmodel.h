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

#ifndef CROPSTATMODEL_H
#define CROPSTATMODEL_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT CropStatModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int revenue READ revenue NOTIFY revenueChanged)
    Q_PROPERTY(qreal fieldLength READ fieldLength NOTIFY fieldLengthChanged)
    Q_PROPERTY(qreal greenhouseLength READ greenhouseLength NOTIFY greenhouseLengthChanged)
    Q_PROPERTY(int varietyNumber READ varietyNumber NOTIFY varietyNumberChanged)

public:
    explicit CropStatModel(QObject *parent = nullptr, const QString &tableName = "crop_stat_view");

    int revenue() const;
    qreal fieldLength() const;
    qreal greenhouseLength() const;
    int varietyNumber() const;

signals:
    void revenueChanged();
    void fieldLengthChanged();
    void greenhouseLengthChanged();
    void varietyNumberChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    qreal length(bool greenhouse) const;
};

#endif // CROPSTATMODEL_H
