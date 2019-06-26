#include "notemodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

NoteModel::NoteModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    sort(0);
}

int NoteModel::plantingId() const
{
    return m_plantingId;
}

void NoteModel::setPlantingId(int plantingId)
{
    if (m_plantingId == plantingId)
        return;

    m_plantingId = plantingId;
    invalidateFilter();
    emit plantingIdChanged();
}

bool NoteModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    int leftCrop = rowValue(left.row(), left.parent(), "planting_id").toInt();
    int rightCrop = rowValue(right.row(), right.parent(), "planting_id").toInt();

    return leftCrop < rightCrop;
}

bool NoteModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_plantingId < 0)
        return SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    int plantingId = rowValue(sourceRow, sourceParent, "planting_id").toInt();
    return plantingId == m_plantingId
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
