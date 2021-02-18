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

#include <QSqlRecord>

#include "familymodel.h"
#include "services/familyservice.h"
#include "version.h"

FamilyModel::FamilyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("family");
}

const QHash<int, QByteArray> FamilyModel2::sRoleNames = { { FamilyRole::name, "family" },
                                                          { FamilyRole::interval, "interval" },
                                                          { FamilyRole::color, "color" },
                                                          { FamilyRole::id, "family_id" },
                                                          { FamilyRole::deleted, "deleted" } };

FamilyModel2::FamilyModel2(FamilyService *svcFamily, QObject *parent)
    : QAbstractListModel(parent)
    , m_svcFamily(svcFamily)
{
    connect(m_svcFamily, &FamilyService::beginResetFamilyModel, this, [=]() { beginResetModel(); });
    connect(m_svcFamily, &FamilyService::endResetFamilyModel, this, [=]() { endResetModel(); });
    connect(m_svcFamily, &FamilyService::familyUpdated, this, [=](int row) {
        QModelIndex idx = index(row);
        if (idx.isValid())
            emit dataChanged(idx, idx);
    });

    connect(svcFamily, &FamilyService::familyVisible, this, [=](int familyId) {
        qDebug() << "[familyVisible] familyId: " << familyId;
        int row = svcFamily->familyRow(familyId);
        if (row != -1) {
            QModelIndex idx = index(row);
            if (idx.isValid()) {
                qDebug() << "[familyVisible] dataChanged!";
                emit dataChanged(idx, idx);
            }
        }
    });

    connect(svcFamily, &FamilyService::beginAppendFamily, this, [=]() {
        qDebug() << "[beginAppendFamily]";
        int lastRow = rowCount();
        beginInsertRows(QModelIndex(), lastRow, lastRow);
    });
    connect(svcFamily, &FamilyService::endAppendFamily, this, [=]() {
        qDebug() << "[endAppendFamily]";
        endInsertRows();
    });
}

int FamilyModel2::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_svcFamily)
        return 0;

    return m_svcFamily->numberOfFamilies();
}

QVariant FamilyModel2::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_svcFamily)
        return QVariant();

    qrp::Family *family = m_svcFamily->familyFromIndexRow(index.row());
    if (!family)
        return QVariant();

    switch (role) {
    case FamilyRole::name:
        return family->name;
    case FamilyRole::interval:
        return family->interval;
    case FamilyRole::color:
        return family->color;
    case FamilyRole::id:
        return family->id;
    case FamilyRole::deleted:
        return family->deleted;
    }

    return QVariant();
}

Qt::ItemFlags FamilyModel2::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

FamilyProxyModel::FamilyProxyModel(FamilyService *svcFamily, QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new FamilyModel2(svcFamily))
{
    setSourceModel(m_model);
    setSortRole(FamilyModel2::FamilyRole::name);
    sort(0, Qt::AscendingOrder);
    setDynamicSortFilter(true);
#ifdef TRACE_CPP_MODELS
    qDebug() << "[FamilyProxyModel] Create";
#endif
}

FamilyProxyModel::~FamilyProxyModel()
{
    delete m_model;
#ifdef TRACE_CPP_MODELS
    qDebug() << "[FamilyProxyModel] Delete";
#endif
}

bool FamilyProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex modelIndex = m_model->index(sourceRow, 0, sourceParent);
    return modelIndex.isValid() ? !m_model->data(modelIndex, FamilyModel2::deleted).toBool() : false;
}
