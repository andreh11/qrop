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

#ifndef SEEDLISTQUARTERMODEL_H
#define SEEDLISTQUARTERMODEL_H

#include <QObject>

#include "core_global.h"
#include "seedlistmodel.h"

class CORESHARED_EXPORT SeedListQuarterModel : public SeedListModel
{
    Q_OBJECT
public:
    explicit SeedListQuarterModel(QObject *parent = nullptr,
                                  const QString &tableName = "seed_list_quarter_view");

protected:
    int groupLessThan(const QModelIndex &left, const QModelIndex &right) const override;
};

#endif // SEEDLISTQUARTERMODEL_H
