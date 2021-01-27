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
};

CropModel2::CropModel2(QObject *parent)
    : QAbstractListModel(parent)
    , m_familyId(-1)
    , m_family(nullptr)
{
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
    m_family = Qrop::instance()->family(familyId);
    if (!m_family)
        m_familyId = -1;
    endResetModel();
#ifdef TRACE_CPP_MODELS
    qDebug() << "[CropProxyModel] set family: " << (m_family ? m_family->name : QString("none"));
#endif
}

CropProxyModel::CropProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_model(new CropModel2)
{
    setSourceModel(m_model);
    setSortRole(CropModel2::CropRole::name);
    setDynamicSortFilter(true);
    sort(0, Qt::AscendingOrder);
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
