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

#include "seedcompanymodel.h"
#include "qrop.h"
SeedCompanyModel::SeedCompanyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("seed_company");
}

const QHash<int, QByteArray> SeedCompanyModel2::sRoleNames = {
    { SeedCompanyRole::name, "seed_company" },
    { SeedCompanyRole::isDefault, "is_default" },
    { SeedCompanyRole::id, "seed_commpany_id" },
};

SeedCompanyModel2::SeedCompanyModel2(Qrop *qrop, QObject *parent)
    : QAbstractListModel(parent)
    , m_qrop(qrop)
{
    connect(m_qrop, &Qrop::beginResetSeedCompanyModel, this, [=]() { beginResetModel(); });
    connect(m_qrop, &Qrop::endResetSeedCompanyModel, this, [=]() { endResetModel(); });
}

int SeedCompanyModel2::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_qrop)
        return 0;

    return m_qrop->numberOfSeedCompanies();
}

QVariant SeedCompanyModel2::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_qrop)
        return QVariant();

    qrp::SeedCompany *seedCompany = m_qrop->seedCompanyFromIndexRow(index.row());
    if (!seedCompany)
        return QVariant();

    switch (role) {
    case SeedCompanyRole::name:
        return seedCompany->name;
    case SeedCompanyRole::isDefault:
        return seedCompany->isDefault;
    case SeedCompanyRole::id:
        return seedCompany->id;
    }

    return QVariant();
}

Qt::ItemFlags SeedCompanyModel2::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}
