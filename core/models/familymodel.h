/*
 * Copyright (C) 2018-2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#ifndef FAMILYTABLE_H
#define FAMILYTABLE_H

#include <QObject>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT FamilyModel : public SortFilterProxyModel
{
public:
    FamilyModel(QObject *parent = nullptr, const QString &tableName = "family");
};

#include <QAbstractListModel>
class Qrop;

class FamilyModel2 : public QAbstractListModel
{
    static const QHash<int, QByteArray> sRoleNames;

public:
    explicit FamilyModel2(Qrop *qrop, QObject *parent = nullptr);

    enum FamilyRole { name = Qt::UserRole, interval, color, id };

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override { return sRoleNames; }
    static QString roleName(int r) { return sRoleNames.value(r); }

private:
    Qrop *m_qrop;
};

#endif // FAMILYTABLE_H
