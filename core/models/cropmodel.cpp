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

#include <QDebug>
#include "sqltablemodel.h"
#include "cropmodel.h"
#include "qrop.h"
#include "version.h"
#include "services/familyservice.h"

CropModel::CropModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop");
    setFilterKeyStringColumn("crop");
}

int CropModel::familyId() const
{
    return m_familyId;
}

void CropModel::setFamilyId(int familyId)
{
    if (familyId == m_familyId) {
        return;
    }
    m_familyId = familyId;

    if (m_familyId > 0) {
        const QString filterString = QString::fromLatin1("family_id = %1").arg(familyId);
        m_model->setFilter(filterString);
    }

    emit familyIdChanged();
}

const QHash<int, QByteArray> CropModel2::sRoleNames = {
    { CropRole::name, "crop" },
    { CropRole::color, "color" },
    { CropRole::id, "crop_id" },
    { CropRole::deleted, "deleted" },
};

CropModel2::CropModel2(QObject *parent)
    : QAbstractListModel(parent)
    , m_familyId(-1)
    , m_family(nullptr)
{
    FamilyService *svcFamily = Qrop::instance()->familyService();
    connect(svcFamily, &FamilyService::cropUpdated, this, [=](int familyId, int srcRow) {
        qDebug() << "[cropUpdated] familyId: " << familyId << ", m_familyId: " << m_familyId
                 << ", row: " << srcRow;
        if (familyId != m_familyId)
            return;
        QModelIndex idx = index(srcRow);
        if (idx.isValid()) {
            qDebug() << "[cropUpdated] dataChanged!";
            emit dataChanged(idx, idx);
        }
    });

    connect(svcFamily, &FamilyService::cropVisible, this, [=](int familyId, int cropId) {
        qDebug() << "[cropVisible] familyId: " << familyId << ", m_familyId: " << m_familyId
                 << ", cropId: " << cropId;
        if (familyId != m_familyId)
            return; // not concerned
        qrp::Family *family = svcFamily->family(familyId);
        if (family) {
            QModelIndex idx = index(family->row(cropId));
            if (idx.isValid()) {
                qDebug() << "[cropVisible] dataChanged!";
                emit dataChanged(idx, idx);
            }
        }
    });

    connect(svcFamily, &FamilyService::beginAppendCrop, this, [=](int familyId) {
        qDebug() << "[beginAppendCrop] familyId: " << familyId << ", m_familyId: " << m_familyId;
        if (familyId != m_familyId)
            return;
        int lastRow = rowCount();
        beginInsertRows(QModelIndex(), lastRow, lastRow);
    });
    connect(svcFamily, &FamilyService::endAppendCrop, this, [=](int familyId) {
        qDebug() << "[endAppendCrop] familyId: " << familyId << ", m_familyId: " << m_familyId;
        if (familyId != m_familyId)
            return;
        endInsertRows();
    });
}

int CropModel2::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_family)
        return 0;

    return m_family->crops.size();
}

QVariant CropModel2::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_family)
        return QVariant();

    qrp::Crop *crop = m_family->crop(index.row());
    if (!crop)
        return QVariant();

    switch (role) {
    case CropRole::name:
        return crop->name;
    case CropRole::color:
        return crop->color;
    case CropRole::id:
        return crop->id;
    case CropRole::deleted:
        return crop->deleted;
    }

    return QVariant();
}

Qt::ItemFlags CropModel2::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

void CropModel2::setFamilyId(int familyId)
{
    beginResetModel();
    m_family = Qrop::instance()->familyService()->family(familyId);
    if (m_family)
        m_familyId = familyId;
    else
        m_familyId = -1;
    endResetModel();
#ifdef TRACE_CPP_MODELS
    qDebug() << "[CropModel2] set family: " << (m_family ? m_family->name : QString("none"));
#endif
}

CropProxyModel::CropProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new CropModel2)
{
    setSourceModel(m_model);
    setSortRole(CropModel2::CropRole::name);
    sort(0, Qt::AscendingOrder);
    setDynamicSortFilter(true);
#ifdef TRACE_CPP_MODELS
    qDebug() << "[CropProxyModel] Create";
#endif
}

CropProxyModel::~CropProxyModel()
{
    delete m_model;
#ifdef TRACE_CPP_MODELS
    qDebug() << "[CropProxyModel] Delete";
#endif
}

bool CropProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex modelIndex = m_model->index(sourceRow, 0, sourceParent);
    if (!modelIndex.isValid())
        return false;
    if (m_model->data(modelIndex, CropModel2::deleted).toBool())
        return false;
    if (m_model->family()->deleted)
        return false;
    return true;
}
