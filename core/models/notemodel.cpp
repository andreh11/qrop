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
    int leftCrop = sourceRowValue(left.row(), left.parent(), "planting_id").toInt();
    int rightCrop = sourceRowValue(right.row(), right.parent(), "planting_id").toInt();

    return leftCrop < rightCrop;
}

bool NoteModel::hasPlantingId(int sourceRow, const QModelIndex &sourceParent) const
{
    int plantingId = sourceRowValue(sourceRow, sourceParent, "planting_id").toInt();
    return plantingId == m_plantingId;
}

bool NoteModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    return ((m_plantingId < 0) || hasPlantingId(sourceRow, sourceParent))
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
