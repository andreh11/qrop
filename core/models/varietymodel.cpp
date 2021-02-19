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

#include <QDebug>
#include "sqltablemodel.h"
#include "varietymodel.h"
#include "qrop.h"
#include "version.h"
#include "services/familyservice.h"

VarietyModel::VarietyModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setFilterKeyStringColumn("variety");
    setSortColumn("variety");
}

int VarietyModel::cropId() const
{
    return m_cropId;
}

void VarietyModel::setCropId(int cropId)
{
    if (cropId == m_cropId)
        return;

    m_cropId = cropId;
    invalidateFilter();
    emit cropIdChanged();
}

bool VarietyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int cropId = sourceRowValue(sourceRow, sourceParent, "crop_id").toInt();
    return cropId == m_cropId && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

VarietyModel2::VarietyModel2(QObject *parent)
    : QAbstractListModel(parent)
    , m_cropId(-1)
    , m_crop(nullptr)
{
    FamilyService *svcFamily = Qrop::instance()->familyService();
    connect(svcFamily, &FamilyService::varietyUpdated, this, [=](int cropId, int srcRow) {
        qDebug() << "[varietyUpdated] cropId: " << cropId << ", m_cropId: " << m_cropId
                 << ", row: " << srcRow;
        if (cropId != m_cropId)
            return;
        QModelIndex idx = index(srcRow);
        if (idx.isValid()) {
            qDebug() << "[varietyUpdated] dataChanged!";
            emit dataChanged(idx, idx);
        }
    });

    connect(svcFamily, &FamilyService::varietyVisible, this, [=](int cropId, int varietyId) {
        qDebug() << "[varietyVisible] cropId: " << cropId << ", m_cropId: " << m_cropId
                 << ", varietyId: " << varietyId;
        if (cropId != m_cropId)
            return;
        qrp::Crop *crop = svcFamily->crop(cropId);
        if (crop) {
            QModelIndex idx = index(crop->row(varietyId));
            if (idx.isValid()) {
                qDebug() << "[varietyVisible] dataChanged!";
                emit dataChanged(idx, idx);
            }
        }
    });

    connect(svcFamily, &FamilyService::beginAppendVariety, this, [=](int cropId) {
        qDebug() << "[beginAppendVariety] cropId: " << cropId << ", m_cropId: " << m_cropId;
        if (cropId != m_cropId)
            return;
        int lastRow = rowCount();
        beginInsertRows(QModelIndex(), lastRow, lastRow);
    });
    connect(svcFamily, &FamilyService::endAppendVariety, this, [=](int cropId) {
        qDebug() << "[endAppendVariety] cropId: " << cropId << ", m_cropId: " << m_cropId;
        if (cropId != m_cropId)
            return;
        endInsertRows();
    });
}

int VarietyModel2::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_crop)
        return 0;

    return m_crop->varieties.size();
}

QVariant VarietyModel2::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !m_crop)
        return QVariant();

    qrp::Variety *variety = m_crop->variety(index.row());
    if (variety)
        return variety->data(role);
    else
        return QVariant();
}

Qt::ItemFlags VarietyModel2::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsSelectable | Qt::ItemIsEnabled;
}

void VarietyModel2::setCropId(int cropId)
{
    beginResetModel();
    m_crop = Qrop::instance()->familyService()->crop(cropId);
    if (m_crop)
        m_cropId = cropId;
    else
        m_cropId = -1;
    endResetModel();
#ifdef TRACE_CPP_MODELS
    qDebug() << "[VarietyModel2] set crop: " << (m_crop ? m_crop->name : QString("none"));
#endif
}

VarietyProxyModel::VarietyProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new VarietyModel2)
{
    setSourceModel(m_model);
    setSortRole(qrp::Variety::r_name);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setSortLocaleAware(true);
    sort(0, Qt::AscendingOrder);
    setDynamicSortFilter(true);
#ifdef TRACE_CPP_MODELS
    qDebug() << "[VarietyProxyModel] VarietyProxyModel";
#endif
}

VarietyProxyModel::~VarietyProxyModel()
{
    delete m_model;
#ifdef TRACE_CPP_MODELS
    qDebug() << "[VarietyProxyModel] Delete";
#endif
}

int VarietyProxyModel::rowId(int row) const
{
    QModelIndex proxyIdx = index(row, 0);
    if (proxyIdx.isValid())
        return data(proxyIdx, qrp::Variety::r_id).toInt();
    else
        return -1;
}

int VarietyProxyModel::idRow(int id) const
{
    for (int row = 0; row < rowCount(); ++row) {
        if (data(index(row, 0), qrp::Variety::r_id).toInt() == id)
            return row;
    }
    return -1;
}

bool VarietyProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex modelIndex = m_model->index(sourceRow, 0, sourceParent);
    if (!modelIndex.isValid())
        return false;
    if (m_model->data(modelIndex, qrp::Variety::r_deleted).toBool())
        return false;
    qrp::Crop *crop = m_model->crop();
    if (crop->deleted || crop->family->deleted)
        return false;
    return m_string.isEmpty()
            ? true
            : m_model->data(modelIndex, sortRole()).toString().contains(m_string, Qt::CaseInsensitive);
}
