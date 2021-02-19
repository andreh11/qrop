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
#include "services/familyservice.h"
#include "version.h"

SeedCompanyModel::SeedCompanyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("seed_company");
}

const QHash<int, QByteArray> SeedCompanyModel2::sRoleNames = {
    { SeedCompanyRole::name, "seed_company" },
    { SeedCompanyRole::isDefault, "is_default" },
    { SeedCompanyRole::id, "seed_commpany_id" },
    { SeedCompanyRole::deleted, "deleted" },
};

SeedCompanyModel2::SeedCompanyModel2(FamilyService *svcFamily, QObject *parent)
    : QAbstractListModel(parent)
    , m_svcFamily(svcFamily)
{
    connect(m_svcFamily, &FamilyService::beginResetSeedCompanyModel, this,
            [=]() { beginResetModel(); });
    connect(m_svcFamily, &FamilyService::endResetSeedCompanyModel, this, [=]() { endResetModel(); });
}

int SeedCompanyModel2::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_svcFamily)
        return 0;

    return m_svcFamily->numberOfSeedCompanies();
}

QVariant SeedCompanyModel2::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_svcFamily)
        return QVariant();

    qrp::SeedCompany *seedCompany = m_svcFamily->seedCompanyFromIndexRow(index.row());
    if (!seedCompany)
        return QVariant();

    switch (role) {
    case SeedCompanyRole::name:
        return seedCompany->name;
    case SeedCompanyRole::isDefault:
        return seedCompany->isDefault;
    case SeedCompanyRole::id:
        return seedCompany->id;
    case SeedCompanyRole::deleted:
        return seedCompany->deleted;
    }

    return QVariant();
}

Qt::ItemFlags SeedCompanyModel2::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

SeedCompanyProxyModel::SeedCompanyProxyModel(FamilyService *svcFamily, QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new SeedCompanyModel2(svcFamily))
{
    setSourceModel(m_model);
    setSortRole(SeedCompanyModel2::SeedCompanyRole::name);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    sort(0, Qt::AscendingOrder);
    setDynamicSortFilter(true);
#ifdef TRACE_CPP_MODELS
    qDebug() << "[SeedCompanyProxyModel] Create";
#endif
}

SeedCompanyProxyModel::~SeedCompanyProxyModel()
{
    delete m_model;
#ifdef TRACE_CPP_MODELS
    qDebug() << "[SeedCompanyProxyModel] Delete";
#endif
}

bool SeedCompanyProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex modelIndex = m_model->index(sourceRow, 0, sourceParent);
    return modelIndex.isValid() ? !m_model->data(modelIndex, SeedCompanyModel2::deleted).toBool()
                                : false;
}
